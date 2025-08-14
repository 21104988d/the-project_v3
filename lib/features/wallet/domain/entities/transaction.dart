import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String hash;
  final DateTime timestamp;
  final double amount;

  const Transaction({
    required this.hash,
    required this.timestamp,
    required this.amount,
  });

  @override
  List<Object?> get props => [hash, timestamp, amount];
}
