import 'package:dartz/dartz.dart';
import 'package:the_project_v3/core/errors/failures.dart';
import 'package:the_project_v3/core/usecases/usecase.dart';
import 'package:the_project_v3/features/wallet/domain/entities/wallet.dart';
import 'package:the_project_v3/features/wallet/domain/repositories/wallet_repository.dart';

class ImportWallet implements UseCase<Wallet, String> {
  final WalletRepository repository;

  ImportWallet(this.repository);

  @override
  Future<Either<Failure, Wallet>> call(String params) async {
    return await repository.importWallet(params);
  }
}
