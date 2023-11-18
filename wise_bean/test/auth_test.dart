import 'package:test/test.dart';
import 'package:wise_bean/services/auth/auth_exceptions.dart';
import 'package:wise_bean/services/auth/auth_provider.dart';
import 'package:wise_bean/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });
    test('Should not be logged out befor init', () {
      expect(
          provider.logOutUser(),
          throwsA(
            const TypeMatcher<NotInitializedException>(),
          ));
    });

    test('Should be able to be initalized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null before init', () {
      expect(provider.currentUser, null);
    });

    test('Should be able to initialize in less than 2 sec', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Create user should delegate to logInUser function', () async {
      final badEmailUser = provider.createUser(
        id: 'foo@bar.com',
        password: 'anypassword',
      );

      expect(
        badEmailUser,
        throwsA(const TypeMatcher<InvalidCredentialsAuthException>()),
      );

      final user = await provider.createUser(
        id: 'anyemail',
        password: 'anypassword',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () {
      provider.sendVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and log in again', () async {
      await provider.logOutUser();
      await provider.logInUser(id: 'anyemail', password: 'anypassword');

      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String id,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logInUser(id: id, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logInUser({
    required String id,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (id == 'foo@bar.com') throw InvalidCredentialsAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOutUser() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotLoggedInAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
