import 'package:dartz/dartz.dart';
import 'package:the_project_v3/core/errors/failures.dart';
import 'package:the_project_v3/core/usecases/usecase.dart';
import 'package:the_project_v3/features/wallet/domain/entities/transaction.dart';
import 'package:the_project_v3/features/wallet/domain/repositories/wallet_repository.dart';

class GetTransactionHistory implements UseCase<List<Transaction>, String> {
  final WalletRepository repository;

  GetTransactionHistory(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(String params) async {
    return await repository.getTransactionHistory(params);
  }
}
