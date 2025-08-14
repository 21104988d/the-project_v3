import 'package:flutter/material.dart';
import 'package:idenfy_sdk_flutter/idenfy_sdk_flutter.dart';

class KycPage extends StatefulWidget {
  const KycPage({Key? key}) : super(key: key);

  @override
  _KycPageState createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  IdenfyIdentificationResult? _idenfyIdentificationResult;

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
              onPressed: () async {
                final result = await IdenfySdkFlutter.start(
                  IdenfyIdentificationData(
                    authToken: 'your_auth_token', // TODO: Replace with your auth token
                  ),
                );
                setState(() {
                  _idenfyIdentificationResult = result;
                });
              },
              child: const Text('Start KYC'),
            ),
            if (_idenfyIdentificationResult != null)
              Text('KYC Result: ${_idenfyIdentificationResult!.identificationStatus}'),
          ],
        ),
      ),
    );
  }
}
