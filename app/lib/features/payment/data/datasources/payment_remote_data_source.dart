import 'package:the_project_v3/features/payment/domain/entities/transaction.dart';

abstract class PaymentRemoteDataSource {
  Future<String> sendTransaction(Transaction transaction);
  Future<double> calculateHandlingFee(double amount);
}
