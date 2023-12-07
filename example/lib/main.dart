import 'package:flutter/material.dart';
import 'package:media_projection_screenshot/captured_image.dart';
import 'package:media_projection_screenshot/media_projection_screenshot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _screenshotPlugin = MediaProjectionScreenshot();

  CapturedImage? image;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              MaterialButton(
                child: const Text('Request Permission'),
                onPressed: () async {
                  _screenshotPlugin.requestPermission();
                },
              ),
              MaterialButton(
                child: const Text('Take Capture'),
                onPressed: () async {
                  CapturedImage? result = await _screenshotPlugin.takeCapture(x: 0, y: 100, width: 800, height: 600);
                  print(result.toString());
                  setState(() {
                    image = result;
                  });
                },
              ),
              MaterialButton(
                child: const Text('Start Capture'),
                onPressed: () async {
                  final stream = await _screenshotPlugin.startCapture(x: 0, y: 100, width: 800, height: 600);
                  stream?.listen((result) {
                    setState(() {
                      image = CapturedImage.fromMap(Map<String, dynamic>.from(result));
                    });
                  });
                },
              ),
              MaterialButton(
                child: const Text('Stop Capture'),
                onPressed: () async {
                  await _screenshotPlugin.stopCapture();
                },
              ),
              image != null
                  ? Container(
                      padding: const EdgeInsets.all(6),
                      color: Colors.blueAccent,
                      height: 600,
                      child: Image.memory(
                        image!.bytes,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
