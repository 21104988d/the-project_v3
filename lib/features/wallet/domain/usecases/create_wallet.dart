import 'package:dartz/dartz.dart';
import 'package:the_project_v3/core/errors/failures.dart';
import 'package:the_project_v3/core/usecases/usecase.dart';
import 'package:the_project_v3/features/wallet/domain/entities/wallet.dart';
import 'package:the_project_v3/features/wallet/domain/repositories/wallet_repository.dart';

class CreateWallet implements UseCase<Wallet, NoParams> {
  final WalletRepository repository;

  CreateWallet(this.repository);

  @override
  Future<Either<Failure, Wallet>> call(NoParams params) async {
    return await repository.createWallet();
  }
}
