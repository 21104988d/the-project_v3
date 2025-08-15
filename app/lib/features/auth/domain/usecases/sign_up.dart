import 'package:dartz/dartz.dart';
import 'package:the_project_v3/core/errors/failures.dart';
import 'package:the_project_v3/core/usecases/usecase.dart';
import 'package:the_project_v3/features/auth/domain/entities/user.dart';
import 'package:the_project_v3/features/auth/domain/repositories/auth_repository.dart';

class SignUp implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  SignUp(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await repository.signUp(params.email, params.password);
  }
}

class SignUpParams {
  final String email;
  final String password;

  SignUpParams({required this.email, required this.password});
}
