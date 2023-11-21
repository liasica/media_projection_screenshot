import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Uint8List? bytes;

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
                  Uint8List? result = await _screenshotPlugin.takeCapture();
                  setState(() {
                    bytes = result;
                  });
                },
              ),
              bytes != null
                  ? Container(
                      padding: const EdgeInsets.all(6),
                      color: Colors.blueAccent,
                      height: 600,
                      child: Image.memory(
                        bytes!,
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
