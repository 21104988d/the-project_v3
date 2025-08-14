import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_project_v3/core/di/injection_container.dart' as di;
import 'package:the_project_v3/features/auth/presentation/pages/login_page.dart';
import 'package:the_project_v3/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:the_project_v3/features/wallet/presentation/bloc/wallet_bloc.dart';

import 'package:the_project_v3/core/security/jailbreak_detection.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  di.init();

  final bool isJailbroken = await JailbreakDetection.isJailbroken();
  if (isJailbroken) {
    SystemNavigator.pop();
  }

  await CertificatePinning.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payou',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => di.sl<AuthBloc>(),
          ),
          BlocProvider(
            create: (_) => di.sl<WalletBloc>(),
          ),
          BlocProvider(
            create: (_) => di.sl<PaymentBloc>(),
          ),
        ],
        child: const LoginPage(),
      ),
    );
  }
}
