import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:the_project_v3/features/payment/domain/entities/transaction.dart';
import 'package:the_project_v3/features/payment/domain/usecases/send_transaction.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final SendTransaction sendTransaction;

  PaymentBloc({required this.sendTransaction}) : super(PaymentInitial()) {
    on<SendTransactionEvent>((event, emit) async {
      emit(PaymentLoading());
      final failureOrTransactionHash = await sendTransaction(event.transaction);
      failureOrTransactionHash.fold(
        (failure) => emit(PaymentError('Failed to send transaction')),
        (transactionHash) => emit(PaymentLoaded(transactionHash)),
      );
    });
  }
}
