// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:path_provider/path_provider.dart';
import 'package:real_time_detection/utils/my_custom_text_style.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

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
  late Interpreter _interpreter;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeInterpreter();
  }

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

  Future<void> _initializeInterpreter() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
    } catch (e) {
      print("Error loading model: $e");
    }
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

      // Preprocess the image and run inference
      final TensorImage tensorImage = TensorImage.fromFile(imageFile);
      final TensorBuffer outputBuffer =
          TensorBuffer.createFixedSize([1, 1001], TfLiteType.float32);
      _interpreter.run(tensorImage.buffer, outputBuffer.buffer);

      // Process the output and update the result
      final List<String> labels =
          await FileUtil.loadLabels('assets/labels.txt');
      final List<double> probabilities = outputBuffer.getDoubleList();
      final List<String> detectedObjects = [];
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > 0.5) {
          detectedObjects.add(
              "${labels[i]} - ${(probabilities[i] * 100).toStringAsFixed(2)}%");
        }
      }

      setState(() {
        result = detectedObjects.isNotEmpty
            ? detectedObjects.join("\n")
            : "No Object Detected";
      });
      print("Detected Objects: $result");
    } catch (error) {
      print("Error Processing Image: $error");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Error Processing Image"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Object Detection",
          style: myTextStyle24(
              fontWeight: FontWeight.bold, fontColors: Colors.white),
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
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Text(
                result,
                style: const TextStyle(
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
