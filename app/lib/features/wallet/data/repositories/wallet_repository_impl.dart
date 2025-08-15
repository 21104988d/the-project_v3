import 'package:dartz/dartz.dart';
import 'package:the_project_v3/core/errors/failures.dart';
import 'package:the_project_v3/features/wallet/data/datasources/wallet_local_data_source.dart';
import 'package:the_project_v3/features/wallet/domain/entities/wallet.dart';
import 'package:the_project_v3/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:the_project_v3/features/wallet/domain/entities/transaction.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDataSource localDataSource;

  WalletRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Wallet>> createWallet() async {
    try {
      final wallet = await localDataSource.createWallet();
      await localDataSource.cacheWallet(wallet);
      return Right(wallet);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Wallet>> importWallet(String privateKey) async {
    try {
      final wallet = await localDataSource.importWallet(privateKey);
      await localDataSource.cacheWallet(wallet);
      return Right(wallet);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, double>> getWalletBalance(String address) async {
    try {
      final balance = await localDataSource.getWalletBalance(address);
      return Right(balance);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionHistory(String address) async {
    try {
      final transactions = await localDataSource.getTransactionHistory(address);
      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
