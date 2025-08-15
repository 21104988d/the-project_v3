import 'package:dartz/dartz.dart';
import 'package:the_project_v3/core/errors/failures.dart';
import 'package:the_project_v3/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:the_project_v3/features/payment/domain/entities/transaction.dart';
import 'package:the_project_v3/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> sendTransaction(Transaction transaction) async {
    try {
      final transactionHash = await remoteDataSource.sendTransaction(transaction);
      return Right(transactionHash);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
