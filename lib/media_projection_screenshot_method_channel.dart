import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'media_projection_screenshot_platform_interface.dart';

/// An implementation of [MediaProjectionScreenshotPlatform] that uses method channels.
class MethodChannelMediaProjectionScreenshot extends MediaProjectionScreenshotPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('media_projection_screenshot');

  @override
  Future<Uint8List?> takeCapture({int? x, int? y, int? width, int? height}) async {
    Map<String, dynamic>? data;
    if (x != null && y != null && width != null && height != null) {
      data = {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };
    }
    return await methodChannel.invokeMethod<Uint8List?>('takeCapture', data);
  }
}
