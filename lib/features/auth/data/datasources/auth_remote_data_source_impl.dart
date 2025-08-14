import 'package:the_project_v3/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:the_project_v3/features/auth/domain/entities/user.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<User> signIn(String email, String password) async {
    // TODO: Implement real sign in logic
    return const User(id: '1', email: 'test@test.com');
  }

  @override
  Future<User> signUp(String email, String password) async {
    // TODO: Implement real sign up logic
    return const User(id: '1', email: 'test@test.com');
  }

  @override
  Future<void> signOut() async {
    // TODO: Implement real sign out logic
  }
}
