import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:the_project_v3/features/wallet/data/datasources/wallet_local_data_source.dart';
import 'package:the_project_v3/features/wallet/domain/entities/wallet.dart';
import 'package:web3dart/web3dart.dart';

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final Web3Client web3client;

  WalletLocalDataSourceImpl({
    required this.secureStorage,
    required this.web3client,
  });

  @override
  Future<Wallet> createWallet() async {
    final rng = Random.secure();
    final credentials = EthPrivateKey.createRandom(rng);
    final address = await credentials.extractAddress();
    final privateKey = credentials.privateKey.toString();
    final publicKey = credentials.publicKey.toString();

    return Wallet(
      address: address.hex,
      privateKey: privateKey,
      publicKey: publicKey,
    );
  }

  @override
  Future<Wallet> importWallet(String privateKey) async {
    final credentials = EthPrivateKey.fromHex(privateKey);
    final address = await credentials.extractAddress();
    final publicKey = credentials.publicKey.toString();

    return Wallet(
      address: address.hex,
      privateKey: privateKey,
      publicKey: publicKey,
    );
  }

  @override
  Future<void> cacheWallet(Wallet wallet) async {
    await secureStorage.write(key: 'privateKey', value: wallet.privateKey);
  }

  @override
  Future<String> getPrivateKey() async {
    return await secureStorage.read(key: 'privateKey') ?? '';
  }

  @override
  Future<double> getWalletBalance(String address) async {
    // TODO: Implement get wallet balance logic
    return 100.0;
  }

  @override
  Future<List<Transaction>> getTransactionHistory(String address) async {
    // TODO: Implement get transaction history logic
    return [
      Transaction(hash: '0x123', timestamp: DateTime.now(), amount: 10.0),
      Transaction(hash: '0x456', timestamp: DateTime.now(), amount: 20.0),
    ];
  }
}
