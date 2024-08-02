import 'package:flutter/material.dart';

class PlateResultScreen extends StatelessWidget {
  final String licensePlate;
  final VoidCallback onRestart;

  const PlateResultScreen({
    Key? key,
    required this.licensePlate,
    required this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
        title: const Text('License Plate Result',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Recognized License Plate:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                licensePlate,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  onRestart();
                  Navigator.pop(context);
                },
                child: Text('Scan Another License Plate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
