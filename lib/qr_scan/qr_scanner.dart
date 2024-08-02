import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code/qr_scan/qr_scan_content_contact_page.dart';
import 'package:qr_code/qr_scan/qr_scan_content_url_page.dart';
import 'package:qr_code/qr_scan/qr_scan_content_free_text_page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({Key? key}) : super(key: key);

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        isPermissionGranted = true;
      });
    } else if (status.isDenied) {
      PermissionStatus newStatus = await Permission.camera.request();
      setState(() {
        isPermissionGranted = newStatus.isGranted;
      });
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      // Handle scanned QR code data here
      _handleQRCode(scanData.code);
    });
  }

  void _handleQRCode(String? data) {
    if (data != null) {
      controller?.pauseCamera();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            if (data.startsWith('BEGIN:VCARD')) {
              return DisplayScannedContentPage(data: data);
            } else if (_isURL(data)) {
              return DisplayScannedContentPageURL(data: data);
            } else {
              return DisplayScannedContentPageText(data: data);
            }
          },
        ),
      ).then((value) {
        controller?.resumeCamera();
      });
    }
  }

  bool _isURL(String data) {
    // Improved regex for URL validation including path after TLD
    final regex = RegExp(
      r'^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(\/[^\s]*)?$',
      caseSensitive: false,
    );
    return regex.hasMatch(data);
  }

  String _normalizeUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      if (url.startsWith('www.')) {
        return 'https://$url';
      }
      return 'https://$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
        title: const Text(
          "QR Scanner",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: isPermissionGranted
          ? QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.green,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            )
          : Center(
              child: ElevatedButton(
                onPressed: _requestCameraPermission,
                child: Text('Request Camera Permission'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
    );
  }
}
