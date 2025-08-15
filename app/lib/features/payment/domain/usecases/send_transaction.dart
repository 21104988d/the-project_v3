import 'package:dartz/dartz.dart';
import 'package:the_project_v3/core/errors/failures.dart';
import 'package:the_project_v3/core/usecases/usecase.dart';
import 'package:the_project_v3/features/payment/domain/entities/transaction.dart';
import 'package:the_project_v3/features/payment/domain/repositories/payment_repository.dart';

class SendTransaction implements UseCase<String, Transaction> {
  final PaymentRepository repository;

  SendTransaction(this.repository);

  @override
  Future<Either<Failure, String>> call(Transaction params) async {
    return await repository.sendTransaction(params);
  }
}
