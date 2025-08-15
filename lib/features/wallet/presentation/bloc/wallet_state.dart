import 'package:the_project_v3/features/wallet/domain/entities/transaction.dart' as WalletTransaction;
import 'package:the_project_v3/features/payment/domain/entities/transaction.dart' as PaymentTransaction;
part of 'wallet_bloc.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Wallet wallet;
  final List<WalletTransaction.Transaction> transactions;

  const WalletLoaded(this.wallet, this.transactions);

  @override
  List<Object> get props => [wallet, transactions];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object> get props => [message];
}
