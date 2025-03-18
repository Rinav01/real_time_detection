import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
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
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Object Detection",
          style: myTextStyle24(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Center(child: SizedBox(width: MediaQuery.of(context).size.width,
            child: isCameraReady ? CameraPreview(_cameraController):Center(child: CircularProgressIndicator()),
            ),)
          ],
        ),
      ),
    );
  }
}
