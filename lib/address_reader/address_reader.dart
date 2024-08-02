import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:camera/camera.dart';
import 'package:qr_code/address_reader/result_screen.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class AddressReaderPage extends StatefulWidget {
  @override
  _AddressReaderPageState createState() => _AddressReaderPageState();
}

class _AddressReaderPageState extends State<AddressReaderPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  final TextRecognizer _textRecognizer = TextRecognizer();
  final EntityExtractor _entityExtractor =
      EntityExtractor(language: EntityExtractorLanguage.turkish);
  bool _isProcessing = false;
  String _address = '';

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    await _cameraController.initialize();
    _cameraController.startImageStream(_processCameraImage);
  }

  Future<void> _processCameraImage(CameraImage cameraImage) async {
    if (_isProcessing) return;

    _isProcessing = true;

    try {
      // Convert CameraImage to InputImage
      final inputImage = _convertCameraImageToInputImage(cameraImage);

      // Process the image file with Google ML Kit's text recognizer.
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      // Extract the text from the recognized text.
      String text = '';
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          text += line.text + '\n';
        }
      }

      // Process the text with Google ML Kit's entity extractor.
      final List<EntityAnnotation> annotations =
          await _entityExtractor.annotateText(text);

      // Extract the address entity.
      for (final annotation in annotations) {
        for (final entity in annotation.entities) {
          if (entity.type == EntityType.address) {
            setState(() {
              _address = annotation.text;
            });

            if (_address.isNotEmpty) {
              // Stop the image stream
              await _cameraController.stopImageStream();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(address: _address),
                ),
              ).then((_) {
                // Reset state when coming back from ResultScreen
                setState(() {
                  _address = '';
                });
                _cameraController.startImageStream(_processCameraImage);
              });

              return;
            }
          }
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

  @override
  void dispose() {
    _cameraController.dispose();
    _textRecognizer.close();
    _entityExtractor.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
        title: const Text('Address Reader',
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
