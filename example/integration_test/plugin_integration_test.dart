// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:media_projection_screenshot/media_projection_screenshot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('takeCapture test', (WidgetTester tester) async {
    final MediaProjectionScreenshot plugin = MediaProjectionScreenshot();
    final Uint8List? image = await plugin.takeCapture();
    expect(image?.isNotEmpty, true);
  });
}
