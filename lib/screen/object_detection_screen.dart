import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:path_provider/path_provider.dart';
import 'package:real_time_detection/utils/my_custom_text_style.dart';

class ObjectDetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ObjectDetectionScreen({super.key, required this.cameras});

  @override
  State<ObjectDetectionScreen> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  late CameraController _cameraController;
  bool isCameraReady = false;
  String result = "Detecting...";
  late ImageLabeler _imageLabeler;
  bool isDetecting = false;

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(
        widget.cameras[0], ResolutionPreset.high,
        enableAudio: false);
    await _cameraController.initialize();
    if (!mounted) return;
    setState(() {
      isCameraReady = true;
    });
    startImageStream();
  }

  void _initializeMLKit() {
    _imageLabeler =
        ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
  }

  void startImageStream() {
    _cameraController.startImageStream((CameraImage image) async {
      if (isDetecting) return;
      isDetecting = true;
      await _processImage(image);
      isDetecting = false;
    });
  }

  Future<void> _processImage(CameraImage cameraImage) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          "${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}.jpg";
      final File imageFile = File(filePath);

      final XFile picture = await _cameraController.takePicture();
      await picture.saveTo(filePath);

      final inputImage = InputImage.fromFilePath(filePath);

      final List<ImageLabel> labels =
          await _imageLabeler.processImage(inputImage);

      String detectedObjects = labels.isNotEmpty
          ? labels
              .map(
                (label) =>
                    "${label.label} - ${(label.confidence * 100).toStringAsFixed(2)}%",
              )
              .join("\n")
          : "No Object Detected";
      setState(() {
        result = detectedObjects;
      });
      print("Detected Objects: $detectedObjects");
    } catch (error) {
      print("Error Processing Image: $error");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error Processing Image"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeMLKit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Object Detection",
          style: myTextStyle24(fontWeight: FontWeight.bold , fontColors: Colors.white ),
        ),
        backgroundColor: const Color(0xff022246),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xff022246),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: isCameraReady
                    ? CameraPreview(_cameraController)
                    : Center(child: CircularProgressIndicator()),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Text(
                result,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
