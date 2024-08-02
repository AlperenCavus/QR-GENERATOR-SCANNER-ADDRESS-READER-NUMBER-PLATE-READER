import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class WebsiteQrCodePage extends StatelessWidget {
  final String data;

  void _shareQrCode(BuildContext context) {
    try {
      Share.share(data);
    } catch (e) {
      print("Error sharing QR code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error sharing QR code: $e"),
        ),
      );
    }
  }

  const WebsiteQrCodePage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
        title: const Text("QR Code",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 150,
                ),
                Text(
                  textAlign: TextAlign.center,
                  "QR Code for the link: $data",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(
                  height: 50,
                ),
                Center(
                  child: QrImageView(
                    data: data,
                    version: QrVersions.auto,
                    size: 300.0,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                IconButton(
                  onPressed: () => _shareQrCode(context),
                  icon: const Icon(Icons.share),
                  color: Colors.green,
                ),
                const Text(
                  "Share",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
