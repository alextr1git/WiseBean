class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C in CRUD
class CouldNotCreateReviewException extends CloudStorageException {}

//R in CRUD
class CouldNotGetAllReviewsException extends CloudStorageException {}

// U in CRUD
class CouldNotUpdateReviewException extends CloudStorageException {}

// D in CRUD
class CouldNotDeleteReviewException extends CloudStorageException {}
