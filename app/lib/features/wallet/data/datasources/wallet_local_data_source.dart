import 'package:the_project_v3/features/wallet/domain/entities/transaction.dart';
import 'package:the_project_v3/features/wallet/domain/entities/wallet.dart';

abstract class WalletLocalDataSource {
  Future<Wallet> createWallet();
  Future<Wallet> importWallet(String privateKey);
  Future<void> cacheWallet(Wallet wallet);
  Future<String> getPrivateKey();
  Future<double> getWalletBalance(String address);
  Future<List<Transaction>> getTransactionHistory(String address);
}