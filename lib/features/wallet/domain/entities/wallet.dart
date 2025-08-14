import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String address;
  final String privateKey;
  final String publicKey;
  final double balance;

  const Wallet({
    required this.address,
    required this.privateKey,
    required this.publicKey,
    required this.balance,
  });

  @override
  List<Object?> get props => [address, privateKey, publicKey, balance];

  Wallet copyWith({
    String? address,
    String? privateKey,
    String? publicKey,
    double? balance,
  }) {
    return Wallet(
      address: address ?? this.address,
      privateKey: privateKey ?? this.privateKey,
      publicKey: publicKey ?? this.publicKey,
      balance: balance ?? this.balance,
    );
  }
}
