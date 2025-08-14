import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_project_v3/features/payment/presentation/pages/generate_qr_page.dart';
import 'package:the_project_v3/features/payment/presentation/pages/scan_qr_page.dart';
import 'package:the_project_v3/features/wallet/presentation/bloc/wallet_bloc.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payou Wallet'),
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletInitial) {
            BlocProvider.of<WalletBloc>(context).add(CreateWalletEvent());
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is WalletLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is WalletLoaded) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                      bottomRight: Radius.circular(32.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        '\$${state.wallet.balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = state.transactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          leading: const Icon(Icons.arrow_outward),
                          title: Text(tx.hash),
                          subtitle: Text(tx.timestamp.toString()),
                          trailing: Text(
                            '-\$${tx.amount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is WalletError) {
            return Center(
              child: Text(state.message),
            );
          }
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text('Scan QR Code'),
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScanQrPage(),
                        ),
                      );
                      if (result != null) {
                        // TODO: Handle payment
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.qr_code),
                    title: const Text('Generate QR Code'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GenerateQrPage(walletAddress: (context.read<WalletBloc>().state as WalletLoaded).wallet.address),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.qr_code),
      ),
    );
  }
}