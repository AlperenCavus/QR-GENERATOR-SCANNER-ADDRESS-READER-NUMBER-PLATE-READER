import 'package:flutter/material.dart';
import 'package:qr_code/qr_generate/website_qr_code_page.dart';

class WebsitePage extends StatefulWidget {
  const WebsitePage({Key? key}) : super(key: key);

  @override
  State<WebsitePage> createState() => _WebsitePageState();
}

class _WebsitePageState extends State<WebsitePage> {
  TextEditingController t1 = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
        title: const Text("Website QR Code",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 150),
                  TextFormField(
                    controller: t1,
                    decoration: const InputDecoration(
                      labelText: 'Website Link',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a URL';
                      } else if (!isValidURL(value)) {
                        return 'Please enter a valid URL';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  buildElevatedButton(
                    text: "Generate QR for Website",
                    icon: Icons.qr_code,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton buildElevatedButton(
      {required String text, required IconData icon}) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          String qrData = t1.text.toString();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebsiteQrCodePage(data: qrData)),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.greenAccent],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isValidURL(String url) {
    const urlPattern =
        r'^(https?:\/\/)?((([a-z0-9][a-z0-9-]*[a-z0-9]?)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(:\d+)?(\/.*)?$';
    final result = RegExp(urlPattern, caseSensitive: false).hasMatch(url);
    return result;
  }
}
