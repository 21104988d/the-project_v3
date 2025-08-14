import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:the_project_v3/core/usecases/usecase.dart';
import 'package:the_project_v3/features/wallet/domain/entities/wallet.dart';
import 'package:the_project_v3/features/wallet/domain/usecases/create_wallet.dart';
import 'package:the_project_v3/features/wallet/domain/usecases/import_wallet.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final CreateWallet createWallet;
  final ImportWallet importWallet;

  WalletBloc({
    required this.createWallet,
    required this.importWallet,
  }) : super(WalletInitial()) {
    on<CreateWalletEvent>((event, emit) async {
      emit(WalletLoading());
      final failureOrWallet = await createWallet(NoParams());
      failureOrWallet.fold(
        (failure) => emit(WalletError('Failed to create wallet')),
        (wallet) => emit(WalletLoaded(wallet)),
      );
    });
    on<ImportWalletEvent>((event, emit) async {
      emit(WalletLoading());
      final failureOrWallet = await importWallet(event.privateKey);
      failureOrWallet.fold(
        (failure) => emit(WalletError('Failed to import wallet')),
        (wallet) => emit(WalletLoaded(wallet, [])),
      );
    });
    on<GetWalletDataEvent>((event, emit) async {
      emit(WalletLoading());
      final failureOrBalance = await getWalletBalance(event.address);
      final failureOrTransactions = await getTransactionHistory(event.address);

      failureOrBalance.fold(
        (failure) => emit(WalletError('Failed to get wallet data')),
        (balance) {
          failureOrTransactions.fold(
            (failure) => emit(WalletError('Failed to get wallet data')),
            (transactions) {
              final wallet = (state as WalletLoaded).wallet.copyWith(balance: balance);
              emit(WalletLoaded(wallet, transactions));
            },
          );
        },
      );
    });
  }
}
