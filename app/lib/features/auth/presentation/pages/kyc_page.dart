import 'package:flutter/material.dart';

class KycPage extends StatelessWidget {
  const KycPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // TODO: Implement KYC logic here
                print('Start KYC button pressed');
              },
              child: const Text('Start KYC'),
            ),
          ],
        ),
      ),
    );
  }
}