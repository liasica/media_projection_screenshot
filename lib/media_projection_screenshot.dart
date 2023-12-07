import 'package:flutter/services.dart';
import 'package:media_projection_creator/media_projection_creator.dart';
import 'package:media_projection_screenshot/captured_image.dart';

import 'media_projection_screenshot_platform_interface.dart';

class MediaProjectionScreenshot {
  // is permission granted
  static bool _isGranted = false;
  static bool get isGranted => _isGranted;

  final _captureStream = const EventChannel('com.liasica.media_projection_screenshot/event').receiveBroadcastStream();

  /// request permission
  /// return [int] errorCode
  /// 0: succeed
  /// 1: user canceled
  /// 2: system version too low
  Future<int> requestPermission() async {
    if (!isGranted) {
      int errorCode = await MediaProjectionCreator.createMediaProjection();
      if (errorCode == MediaProjectionCreator.ERROR_CODE_SUCCEED) {
        _isGranted = true;
      }
      return errorCode;
    }
    return 0;
  }

  /// take capture
  /// return captured image [CapturedImage]
  /// x: capture from [int] x
  /// y: capture to [int] y
  /// width: capture width pixels [int]
  /// height: capture size height pixels [int]
  /// if x, y, width, height are booth null, capture full screen
  /// if x, y, width, height are booth not null, capture specified area
  Future<CapturedImage?> takeCapture({int? x, int? y, int? width, int? height}) async {
    await requestPermission();
    if (!isGranted) {
      return null;
    }
    return await MediaProjectionScreenshotPlatform.instance.takeCapture(x: x, y: y, width: width, height: height);
  }

  Future<Stream<dynamic>?> startCapture({int? x, int? y, int? width, int? height, int fps = 15}) async {
    try {
      if (await MediaProjectionScreenshotPlatform.instance.startCapture(x: x, y: y, width: width, height: height, fps: fps)) {
        return _captureStream;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> stopCapture() async {
    return await MediaProjectionScreenshotPlatform.instance.stopCapture();
  }
}
