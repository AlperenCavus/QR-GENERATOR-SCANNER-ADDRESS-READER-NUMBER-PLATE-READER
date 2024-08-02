import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ResultScreen extends StatelessWidget {
  final String address;

  const ResultScreen({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: Colors.green,
          title: const Text('Extracted Address',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                address,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.black),
                    onPressed: () {
                      // Share the address
                      _shareAddress(context, address);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.black),
                    onPressed: () {
                      // Copy the address
                      _copyAddress(context, address);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Open in Google Maps',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  // Open Google Maps with the address
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GoogleMapsScreen(address: address)),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Scan Another Address',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareAddress(BuildContext context, String address) async {
    await Share.share('Check out this address: $address');
  }

  void _copyAddress(BuildContext context, String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address copied to clipboard')),
    );
  }
}

class GoogleMapsScreen extends StatelessWidget {
  final String address;

  const GoogleMapsScreen({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps')),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=$address'))
          ..setJavaScriptMode(JavaScriptMode.unrestricted),
      ),
    );
  }
}
