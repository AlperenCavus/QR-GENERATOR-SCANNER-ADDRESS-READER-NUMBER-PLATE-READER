import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:qr_code/address_reader/address_reader.dart';
import 'package:qr_code/license_plate_reader/plate_reader.dart';
import 'package:qr_code/qr_generate/qr_generator.dart';
import 'package:qr_code/qr_scan/qr_scanner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterContacts
      .requestPermission(); // Request permission here if needed
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Generator-Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 130),
                buildElevatedButton(
                  text: "QR Generator",
                  icon: Icons.qr_code,
                  onPressed: () {
                    // Navigate to QR Generator page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const QrGeneratorPage()),
                    );
                  },
                ),
                const SizedBox(height: 50),
                buildElevatedButton(
                  text: "QR Reader",
                  icon: Icons.qr_code_scanner,
                  onPressed: () {
                    // Navigate to QR Reader page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const QrScannerPage()),
                    );
                  },
                ),
                const SizedBox(height: 50),
                buildElevatedButton(
                  text: "Address Reader",
                  icon: Icons.camera_alt,
                  onPressed: () {
                    // Navigate to Address Reader page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddressReaderPage()),
                    );
                  },
                ),
                const SizedBox(height: 50),
                buildElevatedButton(
                  text: "License Plate Reader",
                  icon: Icons.directions_car,
                  onPressed: () async {
                    final cameras = await availableCameras();
                    final firstCamera = cameras.first;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PlateReaderPage(camera: firstCamera)),
                    );
                  },
                ),
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
