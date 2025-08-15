import 'package:dartz/dartz.dart';
import 'package:the_project_v3/core/errors/failures.dart';
import 'package:the_project_v3/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:the_project_v3/features/auth/domain/entities/user.dart';
import 'package:the_project_v3/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> signIn(String email, String password) async {
    try {
      final user = await remoteDataSource.signIn(email, password);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> signUp(String email, String password) async {
    try {
      final user = await remoteDataSource.signUp(email, password);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
