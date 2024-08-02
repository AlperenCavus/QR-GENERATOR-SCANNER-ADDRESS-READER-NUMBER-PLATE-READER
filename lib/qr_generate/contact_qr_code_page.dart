import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QrCodePage extends StatelessWidget {
  final String data;

  const QrCodePage({super.key, required this.data});

  void _shareQrCode(BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/contact.vcf');
      await file.writeAsString(data);

      await Share.shareXFiles([XFile(file.path)], text: 'text/x-vcard');
    } catch (e) {
      print("Error sharing QR code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error sharing QR code: $e"),
        ),
      );
    }
  }

  String _extractNameFromVCard(String vCard) {
    final lines = vCard.split('\n');
    for (var line in lines) {
      if (line.startsWith('FN:')) {
        return line.substring(3).trim();
      }
    }
    return 'Unknown'; // Return a default value if no name is found
  }

  @override
  Widget build(BuildContext context) {
    final contactName = _extractNameFromVCard(data);

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
                  "QR Code for the contact: $contactName",
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
                const SizedBox(height: 5),
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
