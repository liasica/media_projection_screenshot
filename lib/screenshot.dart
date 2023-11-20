import 'dart:typed_data';

import 'screenshot_platform_interface.dart';
import 'package:media_projection_creator/media_projection_creator.dart';

class Screenshot {
  // 是否已授权 permission
  static bool _isGranted = false;
  static bool get isGranted => _isGranted;

  Future<Uint8List?> takeCapture({required int x, required int y, required int width, required int height}) async {
    if (!isGranted) {
      int errorCode = await MediaProjectionCreator.createMediaProjection();
      if (errorCode != MediaProjectionCreator.ERROR_CODE_SUCCEED) {
        return null;
      }
      _isGranted = true;
    }
    return await ScreenshotPlatform.instance.takeCapture(x, y, width, height);
  }
}
