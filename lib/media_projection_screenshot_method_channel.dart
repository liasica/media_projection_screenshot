import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_projection_screenshot/captured_image.dart';

import 'media_projection_screenshot_platform_interface.dart';

/// An implementation of [MediaProjectionScreenshotPlatform] that uses method channels.
class MethodChannelMediaProjectionScreenshot extends MediaProjectionScreenshotPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.liasica.media_projection_screenshot/method');

  @override
  Future<CapturedImage?> takeCapture({int? x, int? y, int? width, int? height}) async {
    Map<String, dynamic>? data;
    if (x != null && y != null && width != null && height != null) {
      data = {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };
    }
    final result = await methodChannel.invokeMethod('takeCapture', data);
    if (result == null) {
      return null;
    }
    return CapturedImage.fromMap(Map<String, dynamic>.from(result));
  }

  @override
  Future<bool> startCapture({int? x, int? y, int? width, int? height, int fps = 15}) async {
    Map<String, dynamic>? data;
    if (x != null && y != null && width != null && height != null) {
      data = {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };
    }
    return await methodChannel.invokeMethod('startCapture', data);
  }

  @override
  Future<bool> stopCapture() async {
    return await methodChannel.invokeMethod('stopCapture');
  }
}
