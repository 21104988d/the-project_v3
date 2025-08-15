import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String to;
  final double amount;

  const Transaction({
    required this.to,
    required this.amount,
  });

  @override
  List<Object?> get props => [to, amount];
}
