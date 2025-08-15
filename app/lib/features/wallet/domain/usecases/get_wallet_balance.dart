import 'package:dartz/dartz.dart';
import 'package:the_project_v3/core/errors/failures.dart';
import 'package:the_project_v3/core/usecases/usecase.dart';
import 'package:the_project_v3/features/wallet/domain/repositories/wallet_repository.dart';

class GetWalletBalance implements UseCase<double, String> {
  final WalletRepository repository;

  GetWalletBalance(this.repository);

  @override
  Future<Either<Failure, double>> call(String params) async {
    return await repository.getWalletBalance(params);
  }
}
