import 'package:the_project_v3/features/auth/domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password);
  Future<void> signOut();
}
