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
                child: const Text('Take Capture'),
                onPressed: () async {
                  CapturedImage? result = await _screenshotPlugin.takeCapture(x: 0, y: 100, width: 800, height: 600);
                  print(result.toString());
                  setState(() {
                    image = result;
                  });
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
