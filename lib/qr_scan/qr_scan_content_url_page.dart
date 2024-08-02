import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DisplayScannedContentPageURL extends StatelessWidget {
  final String data;

  const DisplayScannedContentPageURL({Key? key, required this.data})
      : super(key: key);

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _shareData() {
    Share.share(data);
  }

  void _goToWebsite(BuildContext context) {
    final normalizedUrl = _normalizeUrl(data);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewPage(url: normalizedUrl)),
    );
  }

  String _normalizeUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    if (url.startsWith('www.')) {
      return 'https://${url.substring(4)}';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    bool isUrl;
    try {
      Uri.parse(_normalizeUrl(data));
      isUrl = true;
    } catch (e) {
      isUrl = false;
    }
    false;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
        title: const Text(
          "Scanned Content",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Scanned Data:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                data,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _copyToClipboard(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Copy to Clipboard'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _shareData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Share'),
              ),
              if (isUrl) ...[
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _goToWebsite(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Go to Website'),
                ),
              ],
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Scan Another QR Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Uri uri = Uri.parse(url);
    String domain = uri.host;

    // Remove the 'www.' prefix if it exists
    if (domain.startsWith('www.')) {
      domain = domain.substring(4);
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          domain,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse(url))
          ..setJavaScriptMode(JavaScriptMode.unrestricted),
      ),
    );
  }
}
