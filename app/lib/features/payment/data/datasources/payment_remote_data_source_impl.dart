import 'dart:math';

import 'package:the_project_v3/features/payment/data/datasources/erc20_abi.dart';
import 'package:the_project_v3/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:the_project_v3/features/payment/domain/entities/transaction.dart';
import 'package:the_project_v3/features/wallet/data/datasources/wallet_local_data_source.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String companyWalletAddress = '0x284B96E3ac91498F4FAA411AeD28a5c33a2AC2b4';
const String usdcContractAddress = 'your_usdc_contract_address'; // TODO: Replace with actual contract address

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final web3.Web3Client client;
  final WalletLocalDataSource walletLocalDataSource;

  PaymentRemoteDataSourceImpl({required this.client, required this.walletLocalDataSource});

  @override
  Future<String> sendTransaction(Transaction transaction) async {
    final privateKey = await walletLocalDataSource.getPrivateKey();
    final credentials = web3.EthPrivateKey.fromHex(privateKey);
    final toAddress = web3.EthereumAddress.fromHex(transaction.to);
    final value = BigInt.from(transaction.amount * pow(10, 18));

    final usdcContract = DeployedContract(
      ContractAbi.fromJson(erc20Abi, 'PayouUSDC'),
      web3.EthereumAddress.fromHex(dotenv.env['USDC_CONTRACT_ADDRESS']!),
    );

    final transferFunction = usdcContract.function('transfer');

    final transactionHash = await client.sendTransaction(
      credentials,
      web3.Transaction.callContract(
        contract: usdcContract,
        function: transferFunction,
        parameters: [toAddress, value],
      ),
      chainId: 11155111, // Sepolia chain ID
    );

    // TODO: Get company wallet private key from a secure location
    final companyCredentials = web3.EthPrivateKey.fromHex(dotenv.env['COMPANY_PRIVATE_KEY']!);

    final handlingFee = await calculateHandlingFee(transaction.amount);
    final handlingFeeValue = BigInt.from(handlingFee * pow(10, 18));

    await client.sendTransaction(
      companyCredentials,
      web3.Transaction.callContract(
        contract: usdcContract,
        function: transferFunction,
        parameters: [web3.EthereumAddress.fromHex(dotenv.env['COMPANY_WALLET_ADDRESS']!), handlingFeeValue],
      ),
      chainId: 11155111, // Sepolia chain ID
    );

    return transactionHash;
  }

  @override
  Future<double> calculateHandlingFee(double amount) async {
    final gasPrice = await client.getGasPrice(); // web3.EtherAmount
    final gasAmount = BigInt.from(21000); // BigInt

    // Calculate total gas cost in Wei (BigInt)
    final totalGasCostWei = gasPrice.getInWei * gasAmount; // BigInt * BigInt = BigInt

    // Convert total gas cost to Ether (double)
    final double gasFee = web3.EtherAmount.inWei(totalGasCostWei).getInEther.toDouble();
    final handlingFee = gasFee * (log(amount) / log(10) + 0.5);
    return handlingFee;
  }
}