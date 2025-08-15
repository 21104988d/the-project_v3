part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object> get props => [];
}

class SendTransactionEvent extends PaymentEvent {
  final Transaction transaction;

  const SendTransactionEvent(this.transaction);

  @override
  List<Object> get props => [transaction];
}
