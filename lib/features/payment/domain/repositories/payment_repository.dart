import 'package:dartz/dartz.dart';
import 'package:the_project_v3/core/errors/failures.dart';
import 'package:the_project_v3/features/payment/domain/entities/transaction.dart';

abstract class PaymentRepository {
  Future<Either<Failure, String>> sendTransaction(Transaction transaction);
}
