import 'package:flutter/material.dart';
import 'package:qr_code/qr_generate/website_qr_code_page.dart';

class FreeTextPage extends StatefulWidget {
  const FreeTextPage({Key? key}) : super(key: key);

  @override
  State<FreeTextPage> createState() => _FreeTextPageState();
}

class _FreeTextPageState extends State<FreeTextPage> {
  TextEditingController t1 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
        title: const Text("Free Text QR Code",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 150),
                TextFormField(
                  minLines: 3,
                  maxLines: 5,
                  controller: t1,
                  decoration: const InputDecoration(
                    labelText: 'Your Input',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                buildElevatedButton(
                  text: "Generate QR for the Text",
                  icon: Icons.qr_code,
                ),
              ],
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
        String qrData = t1.text.toString();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebsiteQrCodePage(data: qrData)),
        );
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
}
