import 'package:wise_bean/services/auth/auth_provider.dart';
import 'package:wise_bean/services/auth/auth_user.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  const AuthService(this.provider);

  @override
  Future<AuthUser> createUser({
    required String id,
    required String password,
  }) =>
      provider.createUser(
        id: id,
        password: password,
      );
  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logInUser({
    required String id,
    required String password,
  }) =>
      provider.logInUser(
        id: id,
        password: password,
      );

  @override
  Future<void> logOutUser() => provider.logOutUser();

  @override
  Future<void> sendVerification() => provider.sendVerification();
}
