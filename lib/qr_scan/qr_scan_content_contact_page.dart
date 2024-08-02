import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DisplayScannedContentPage extends StatelessWidget {
  final String data;

  const DisplayScannedContentPage({Key? key, required this.data})
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

  Future<void> _saveToContacts(BuildContext context) async {
    if (data.startsWith('BEGIN:VCARD')) {
      try {
        // Parse the vCard data
        final contact = _parseVCard(data);

        // Check for permissions
        if (await FlutterContacts.requestPermission()) {
          // Insert the contact
          await contact.insert();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact saved successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission denied')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save contact: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not a valid vCard')),
      );
    }
  }

  Contact _parseVCard(String vCard) {
    final contact = Contact();

    // Split vCard into lines
    final lines = vCard.split('\n');

    // Extract data from vCard lines
    for (var line in lines) {
      if (line.startsWith('FN:')) {
        final fullName = line.substring(3).trim().split(' ');
        contact.name.first = fullName.isNotEmpty ? fullName[0] : '';
        contact.name.last = fullName.length > 1 ? fullName[1] : '';
      } else if (line.startsWith('TEL;')) {
        final phoneNumber = line.split(':').last.trim();
        if (phoneNumber.isNotEmpty) {
          contact.phones.add(Phone(phoneNumber));
        }
      } else if (line.startsWith('EMAIL;')) {
        final email = line.split(':')[1].trim();
        if (email.isNotEmpty) {
          contact.emails.add(Email(email));
        }
      } else if (line.startsWith('ORG:')) {
        final organizationName = line.substring(4).trim();
        if (organizationName.isNotEmpty) {
          contact.organizations.add(Organization(title: organizationName));
        }
      }
    }

    return contact;
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

  void _makeCall(BuildContext context) async {
    final phoneNumberPattern = RegExp(
      r'TEL;.*:(\+?\d{1,3}[\s-]?\(?\d{1,4}\)?[-\.\s]?\d{1,4}[-\.\s]?\d{1,9})',
    );
    final match = phoneNumberPattern.firstMatch(data);
    if (match != null) {
      final phoneNumber = match.group(1)?.trim();
      final Uri _telUri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(_telUri)) {
        await launchUrl(_telUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to make call')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVCard = data.startsWith('BEGIN:VCARD');
    bool isUrl;
    try {
      Uri.parse(_normalizeUrl(data));
      isUrl = true;
    } catch (e) {
      isUrl = false;
    }
    false;
    ;

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
              if (isVCard) ...[
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _saveToContacts(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save to Contacts'),
                ),
              ],
              if (isVCard) ...[
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _makeCall(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Call'),
                ),
              ],
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
