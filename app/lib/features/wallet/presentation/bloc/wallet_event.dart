part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

class CreateWalletEvent extends WalletEvent {}

class ImportWalletEvent extends WalletEvent {
  final String privateKey;

  const ImportWalletEvent(this.privateKey);

  @override
  List<Object> get props => [privateKey];
}

class GetWalletDataEvent extends WalletEvent {
  final String address;

  const GetWalletDataEvent(this.address);

  @override
  List<Object> get props => [address];
}
