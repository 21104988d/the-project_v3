import 'package:dartz/dartz.dart';
import 'package:the_project_v3/features/wallet/domain/entities/wallet.dart';
import 'package:the_project_v3/core/errors/failures.dart';
import 'package:the_project_v3/features/wallet/domain/entities/transaction.dart';

abstract class WalletRepository {
  Future<Either<Failure, Wallet>> createWallet();
  Future<Either<Failure, Wallet>> importWallet(String privateKey);
  Future<Either<Failure, double>> getWalletBalance(String address);
  Future<Either<Failure, List<Transaction>>> getTransactionHistory(String address);
}
