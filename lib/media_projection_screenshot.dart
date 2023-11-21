import 'dart:typed_data';

import 'package:media_projection_creator/media_projection_creator.dart';

import 'media_projection_screenshot_platform_interface.dart';

class MediaProjectionScreenshot {
  // is permission granted
  static bool _isGranted = false;
  static bool get isGranted => _isGranted;

  /// request permission
  /// return errorCode
  /// 0: succeed
  /// 1: user canceled
  /// 2: system version too low
  Future<int?> requestPermission() async {
    if (!isGranted) {
      int errorCode = await MediaProjectionCreator.createMediaProjection();
      if (errorCode == MediaProjectionCreator.ERROR_CODE_SUCCEED) {
        _isGranted = true;
      }
      return errorCode;
    }
    return null;
  }

  /// take capture
  /// return captured image [Uint8List]
  /// x: capture from [int] x
  /// y: capture to [int] y
  /// width: capture width pixels [int]
  /// height: capture size height pixels [int]
  /// if x, y, width, height are booth null, capture full screen
  /// if x, y, width, height are booth not null, capture specified area
  Future<Uint8List?> takeCapture({int? x, int? y, int? width, int? height}) async {
    await requestPermission();
    if (!isGranted) {
      return null;
    }
    return await MediaProjectionScreenshotPlatform.instance.takeCapture(x: x, y: y, width: width, height: height);
  }
}
