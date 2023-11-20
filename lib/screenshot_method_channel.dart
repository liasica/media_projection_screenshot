import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'screenshot_platform_interface.dart';

/// An implementation of [ScreenshotPlatform] that uses method channels.
class MethodChannelScreenshot extends ScreenshotPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('screenshot');

  @override
  Future<Uint8List?> takeCapture(int x, int y, int width, int height) async {
    return await methodChannel.invokeMethod<Uint8List?>('takeCapture', {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    });
  }
}
