import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:real_time_detection/screen/object_detection_screen.dart';
import 'package:real_time_detection/utils/my_custom_text_style.dart';

class SplashScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const SplashScreen({super.key, required this.cameras});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(seconds: 5), () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ObjectDetectionScreen(cameras: widget.cameras)));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff022246),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 51,
            ),
            Image.asset(
              "assets/icons/loupe.png",
              height: 200,
            ),
            SizedBox(
              height: 8,
            ),
            Text("Blind Assistance",
                style: myTextStyle32(
                    fontWeight: FontWeight.bold, fontColors: Colors.white)),
            Spacer(),
            Text(
              "Powered by K.R.S.",
              style: myTextStyle18(fontColors: Colors.white),
            ),
            SizedBox(
              height: 22,
            )
          ],
        ),
      ),
    );
  }
}
