import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';

import 'package:the_project_v3/features/wallet/data/datasources/wallet_local_data_source.dart';
import 'package:the_project_v3/features/wallet/data/datasources/wallet_local_data_source_impl.dart';
import 'package:the_project_v3/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:the_project_v3/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:the_project_v3/features/wallet/domain/usecases/create_wallet.dart';
import 'package:the_project_v3/features/wallet/domain/usecases/get_transaction_history.dart';
import 'package:the_project_v3/features/wallet/domain/usecases/get_wallet_balance.dart';
import 'package:the_project_v3/features/wallet/domain/usecases/import_wallet.dart';
import 'package:the_project_v3/features/wallet/presentation/bloc/wallet_bloc.dart';

final sl = GetIt.instance;

void init() {
  // BLoC
  sl.registerFactory(
    () => WalletBloc(
      createWallet: sl(),
      importWallet: sl(),
      getWalletBalance: sl(),
      getTransactionHistory: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateWallet(sl()));
  sl.registerLazySingleton(() => ImportWallet(sl()));
  sl.registerLazySingleton(() => GetWalletBalance(sl()));
  sl.registerLazySingleton(() => GetTransactionHistory(sl()));

  // Repository
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<WalletLocalDataSource>(
    () => WalletLocalDataSourceImpl(
      secureStorage: sl(),
      web3client: sl(),
    ),
  );
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(
      client: sl(),
      walletLocalDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  // External
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Web3Client(sl(), http.Client()));
  sl.registerLazySingleton(() => dotenv.env['L2_RPC_URL']!);
}
