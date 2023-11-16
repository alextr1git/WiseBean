import 'package:wise_bean/services/auth/auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;

  Future<AuthUser> logInUser({
    required String id,
    required String password,
  });

  Future<AuthUser> createUser({
    required String id,
    required String password,
  });

  Future<void> logOutUser();
  Future<void> sendVerification();
}
