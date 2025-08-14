import 'dart:math';

import 'package:the_project_v3/features/payment/data/datasources/erc20_abi.dart';
import 'package:the_project_v3/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:the_project_v3/features/payment/domain/entities/transaction.dart';
import 'package:the_project_v3/features/wallet/data/datasources/wallet_local_data_source.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

const String companyWalletAddress = '0x284B96E3ac91498F4FAA411AeD28a5c33a2AC2b4';
const String usdcContractAddress = 'your_usdc_contract_address'; // TODO: Replace with actual contract address

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Web3Client client;
  final WalletLocalDataSource walletLocalDataSource;

  PaymentRemoteDataSourceImpl({required this.client, required this.walletLocalDataSource});

  @override
  Future<String> sendTransaction(Transaction transaction) async {
    final privateKey = await walletLocalDataSource.getPrivateKey();
    final credentials = EthPrivateKey.fromHex(privateKey);
    final toAddress = EthereumAddress.fromHex(transaction.to);
    final value = BigInt.from(transaction.amount * pow(10, 18));

    final usdcContract = DeployedContract(
      ContractAbi.fromJson(erc20Abi, 'PayouUSDC'),
      EthereumAddress.fromHex(dotenv.env['USDC_CONTRACT_ADDRESS']!),
    );

    final transferFunction = usdcContract.function('transfer');

    final transactionHash = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: usdcContract,
        function: transferFunction,
        parameters: [toAddress, value],
      ),
      chainId: 11155111, // Sepolia chain ID
    );

    // TODO: Get company wallet private key from a secure location
    final companyCredentials = EthPrivateKey.fromHex(dotenv.env['COMPANY_PRIVATE_KEY']!);

    final handlingFee = await calculateHandlingFee(transaction.amount);
    final handlingFeeValue = BigInt.from(handlingFee * pow(10, 18));

    await client.sendTransaction(
      companyCredentials,
      Transaction.callContract(
        contract: usdcContract,
        function: transferFunction,
        parameters: [EthereumAddress.fromHex(dotenv.env['COMPANY_WALLET_ADDRESS']!), handlingFeeValue],
      ),
      chainId: 11155111, // Sepolia chain ID
    );

    return transactionHash;
  }

  @override
  Future<double> calculateHandlingFee(double amount) async {
    final gasPrice = await client.getGasPrice();
    final gasAmount = BigInt.from(21000); // Standard gas amount for a simple transaction
    final gasFee = gasPrice.getInEther * EtherAmount.inWei(gasAmount).getInEther;
    final handlingFee = gasFee * (log(amount) / log(10) + 0.5);
    return handlingFee;
  }
}