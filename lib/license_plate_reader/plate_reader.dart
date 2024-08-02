import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:camera/camera.dart';
import 'package:qr_code/license_plate_reader/plate_result_screen.dart';

class PlateReaderPage extends StatefulWidget {
  final CameraDescription camera;

  const PlateReaderPage({Key? key, required this.camera}) : super(key: key);

  @override
  _PlateReaderPageState createState() => _PlateReaderPageState();
}

class _PlateReaderPageState extends State<PlateReaderPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isProcessing = false;
  String _licensePlate = '';

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    await _cameraController.initialize();
    _cameraController.startImageStream(_processCameraImage);
  }

  Future<void> _processCameraImage(CameraImage cameraImage) async {
    if (_isProcessing) return;

    _isProcessing = true;

    try {
      final inputImage = _convertCameraImageToInputImage(cameraImage);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      // Extract text from blocks
      String text = '';
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          text += line.text + '\n';
          print(text);
        }
      }

      // Improved license plate extraction
      final platePattern = RegExp(r'\b\d{2} [A-Z]+ \d{2,4}\b');
      final matches = platePattern.allMatches(text);

      if (matches.isNotEmpty) {
        // Assuming the first match is the most relevant
        final match = matches.first;

        setState(() {
          _licensePlate = match.group(0)!.trim();
        });

        if (_licensePlate.isNotEmpty) {
          _cameraController.stopImageStream();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlateResultScreen(
                licensePlate: _licensePlate,
                onRestart: _restartCamera,
              ),
            ),
          );
          return;
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  InputImage _convertCameraImageToInputImage(CameraImage cameraImage) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize =
        Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());
    final camera = _cameraController.description;
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg;
    final inputImageFormat =
        InputImageFormatValue.fromRawValue(cameraImage.format.raw) ??
            InputImageFormat.nv21;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: cameraImage.planes.first.bytesPerRow,
      ),
    );
  }

  void _restartCamera() {
    _initializeControllerFuture = _initializeCamera();
    setState(() {
      _licensePlate = '';
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
        title: const Text('License Plate Reader',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_cameraController);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
