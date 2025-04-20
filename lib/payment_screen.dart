// import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';


class PaymentScreen extends StatelessWidget {
  final String qrCodeUrl;
  const PaymentScreen({super.key, required this.qrCodeUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Scan QR Code with HelloCash'),
            const SizedBox(height: 20),
            // QrImageView(
            //   data: qrCodeUrl,
            //   size: 200.0,
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment completed!')),
                );
              },
              child: const Text('Confirm Payment'),
            ),
          ],
        ),
      ),
    );
  }
}