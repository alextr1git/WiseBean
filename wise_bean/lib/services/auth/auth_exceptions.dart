//login exceptions
class InvalidCredentialsAuthException implements Exception {}

//register exceptions
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

//generic exceptions
class NetworkRequestFailedAuthException implements Exception {}

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
