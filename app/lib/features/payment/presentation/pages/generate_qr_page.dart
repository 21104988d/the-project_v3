import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQrPage extends StatefulWidget {
  final String walletAddress;

  const GenerateQrPage({Key? key, required this.walletAddress}) : super(key: key);

  @override
  _GenerateQrPageState createState() => _GenerateQrPageState();
}

class _GenerateQrPageState extends State<GenerateQrPage> {
  final TextEditingController _amountController = TextEditingController();
  String? _qrData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_qrData != null)
                  QrImageView(
                    data: _qrData!,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                const SizedBox(height: 50),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _qrData = '{"address": "${widget.walletAddress}", "amount": "${_amountController.text}"}';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Generate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}