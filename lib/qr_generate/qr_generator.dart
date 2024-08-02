import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:qr_code/qr_generate/contact_info.dart';
import 'package:qr_code/qr_generate/contact_qr_code_page.dart';
import 'package:qr_code/qr_generate/free_text.dart';
import 'package:qr_code/qr_generate/website.dart';

class QrGeneratorPage extends StatefulWidget {
  const QrGeneratorPage({super.key});

  @override
  State<QrGeneratorPage> createState() => _QrGeneratorPageState();
}

class _QrGeneratorPageState extends State<QrGeneratorPage> {
  FullContact? fullContact;
  ContactInfo? contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
        title: const Text("QR Generator",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 150),
                buildElevatedButton(
                    text: "Contact Card QR Generator",
                    icon: Icons.perm_contact_cal,
                    onPressed: () async {
                      try {
                        // Use the contact picker
                        fullContact =
                            await FlutterContactPicker.pickFullContact();
                        if (fullContact != null) {
                          setState(() {
                            contact = ContactInfo(
                              name:
                                  '${fullContact!.name?.firstName ?? ''} ${fullContact!.name?.lastName ?? ''}',
                              phone: fullContact!.phones.isNotEmpty
                                  ? fullContact!.phones.first.number
                                  : '',
                              email: fullContact!.emails.isNotEmpty
                                  ? fullContact!.emails.first.email
                                  : '',
                              organization: fullContact!.company ?? '',
                            );
                          });

                          // Generate vCard data
                          String vCardData = contact!.toVCard();

                          // Navigate to the QR code page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QrCodePage(data: vCardData),
                            ),
                          );
                        }
                      } catch (e) {
                        // Handle errors or permission issues here
                        print("Error picking contact: $e");
                      }
                    }),
                const SizedBox(height: 50),
                buildElevatedButton(
                    text: "Website QR Generator",
                    icon: Icons.http,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WebsitePage(),
                        ),
                      );
                    }),
                const SizedBox(height: 50),
                buildElevatedButton(
                    text: "Free Text QR Generator",
                    icon: Icons.text_fields,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FreeTextPage(),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton buildElevatedButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: EdgeInsets.zero,
      ),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Icon(
              icon,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
