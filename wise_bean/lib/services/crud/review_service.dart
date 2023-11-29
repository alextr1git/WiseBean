import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:wise_bean/services/crud/crud_exceptions.dart';

const dbName = 'reviews.db';
const reviewTable = 'review';
const userTable = 'user';

const idColumn = 'id';
const emailColumn = 'email';

const userIdColumn = 'user_id';
const remarksColumn = 'remarks';
const balanceColumn = 'balance';
const enjoymentColumn = 'enjoyment';
const descriptionCorrectnessColumn = 'description_correctness';
const totalRateColumn = 'total_rate';

const createUserTable = '''
  CREATE TABLE IF NOT EXISTS "user" (
    "id"	INTEGER NOT NULL,
    "email"	TEXT NOT NULL UNIQUE,
    PRIMARY KEY("id" AUTOINCREMENT)
  );''';

const createReviewTable = '''
  CREATE TABLE IF NOT EXISTS "review" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"balance"	REAL NOT NULL,
	"enjoyment"	REAL NOT NULL,
	"description_correctness"	REAL NOT NULL,
	"remarks"	TEXT,
	"total_rate"	REAL NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
''';

class ReviewsService {
  Database? _db;

  List<DatabaseReview> _reviews = [];

  //singleton
  static final ReviewsService _shared = ReviewsService._sharedInstance();
  ReviewsService._sharedInstance() {
    _reviewsStreamController = StreamController<List<DatabaseReview>>.broadcast(
      //The onListen callback is provided, which is invoked when
      // a listener subscribes to the stream.
      // In this case, it immediately adds the existing _reviews to the stream's sink.
      onListen: () {
        _reviewsStreamController.sink.add(_reviews);
      },
    );
  }
  factory ReviewsService() => _shared;
  //////

  late final StreamController<List<DatabaseReview>> _reviewsStreamController;

  Stream<List<DatabaseReview>> get allReviews =>
      _reviewsStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheReviews() async {
    final allReviews = await getAllReviews();
    _reviews = allReviews.toList();
    _reviewsStreamController.add(_reviews);
  }

  Future<DatabaseReview> updateReview({
    required DatabaseReview review,
    required String remarks,
    required double balance,
    required double enjoyment,
    required double descriptionCorrectness,
    required double totalRate,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getReview(id: review.id);
    //update db
    final updatesCount = await db.update(
      reviewTable,
      {
        remarksColumn: remarks,
        balanceColumn: balance,
        enjoymentColumn: enjoyment,
        descriptionCorrectnessColumn: descriptionCorrectness,
        totalRateColumn: totalRate,
      },
      where: 'id = ?',
      whereArgs: [review.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateReview();
    } else {
      final updatedReview = await getReview(id: review.id);
      _reviews.removeWhere((review) => review.id == updatedReview.id);
      _reviews.add(updatedReview);
      _reviewsStreamController.add(_reviews);
      return updatedReview;
    }
  }

  Future<Iterable<DatabaseReview>> getAllReviews() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final reviews = await db.query(reviewTable);
    return reviews.map((reviewRow) => DatabaseReview.fromRow(reviewRow));
  }

  Future<DatabaseReview> getReview({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final reviews = await db.query(
      reviewTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (reviews.isEmpty) {
      throw CouldFindReview();
    } else {
      final review = DatabaseReview.fromRow(reviews.first);
      _reviews.removeWhere((review) => review.id == id);
      _reviews.add(review);
      _reviewsStreamController.add(_reviews);
      return review;
    }
  }

  Future<int> deleteAllReviews() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(reviewTable);
    _reviews = [];
    _reviewsStreamController.add(_reviews);

    return numberOfDeletions;
  }

  Future<void> deleteReview({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      reviewTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteReview();
    } else {
      final countBefore = _reviews.length;
      _reviews.removeWhere((review) => review.id == id);
      if (_reviews.length != countBefore) {
        _reviewsStreamController.add(_reviews);
      }
    }
  }

  Future<DatabaseReview> createReview({
    required DatabaseUser owner,
    required String remarks,
    required double balance,
    required double enjoyment,
    required double descriptionCorrectness,
    required double totalRate,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure owner exists in the database with correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    //create the review
    final reviewId = await db.insert(reviewTable, {
      userIdColumn: owner.id,
      remarksColumn: remarks,
      balanceColumn: balance,
      enjoymentColumn: enjoyment,
      descriptionCorrectnessColumn: descriptionCorrectness,
      totalRateColumn: totalRate,
    });

    final review = DatabaseReview(
      id: reviewId,
      userId: owner.id,
      balance: balance,
      enjoyment: enjoyment,
      descriptionCorrectness: descriptionCorrectness,
      remarks: remarks,
      totalRate: totalRate,
    );

    _reviews.add(review);
    _reviewsStreamController.add(_reviews);

    return review;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      //create user table
      await db.execute(createUserTable);
      //create review table
      await db.execute(createReviewTable);

      await _cacheReviews();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseReview {
  final int id;
  final int userId;
  final double balance;
  final double enjoyment;
  final double descriptionCorrectness;
  final String remarks;
  final double totalRate;

  DatabaseReview({
    required this.id,
    required this.userId,
    required this.balance,
    required this.enjoyment,
    required this.descriptionCorrectness,
    required this.remarks,
    required this.totalRate,
  });

  DatabaseReview.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        balance = map[balanceColumn] as double,
        enjoyment = map[enjoymentColumn] as double,
        descriptionCorrectness = map[descriptionCorrectnessColumn] as double,
        remarks = map[remarksColumn] as String,
        totalRate = map[totalRateColumn] as double;

  @override
  String toString() =>
      'Review, ID = $id, userId = $userId, balance = $balance, enjoyment = $enjoyment, descCorrect = $descriptionCorrectness, totalRate =$totalRate, remarks = $remarks,';

  @override
  bool operator ==(covariant DatabaseReview other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
