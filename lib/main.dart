import 'package:flutter/material.dart';
import 'package:video_stream/camera.dart';

List<CameraDescription> cameras = [];


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Get the available device cameras
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    // debugPrint(e.toString());
    logError(e.code, e.description);
  }

  runApp(const MyApp());
}
void logError(String code, String message) =>
    print('Error: $code\nError Message: $message ------------->');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Stream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const Scaffold(),
    );
  }
}