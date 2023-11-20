import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_projection_screenshot/screenshot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _screenshotPlugin = Screenshot();

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
              bytes != null
                  ? Image.memory(
                      bytes!,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    )
                  : Container(),
              MaterialButton(
                child: const Text('Take Capture'),
                onPressed: () async {
                  Uint8List? result = await _screenshotPlugin.takeCapture(x: 0, y: 0, width: 1080, height: 100);
                  setState(() {
                    bytes = result;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
