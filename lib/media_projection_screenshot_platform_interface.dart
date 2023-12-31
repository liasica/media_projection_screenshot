import 'package:media_projection_screenshot/captured_image.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'media_projection_screenshot_method_channel.dart';

abstract class MediaProjectionScreenshotPlatform extends PlatformInterface {
  /// Constructs a MediaProjectionScreenshotPlatform.
  MediaProjectionScreenshotPlatform() : super(token: _token);

  static final Object _token = Object();

  static MediaProjectionScreenshotPlatform _instance = MethodChannelMediaProjectionScreenshot();

  /// The default instance of [MediaProjectionScreenshotPlatform] to use.
  ///
  /// Defaults to [MethodChannelMediaProjectionScreenshot].
  static MediaProjectionScreenshotPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MediaProjectionScreenshotPlatform] when
  /// they register themselves.
  static set instance(MediaProjectionScreenshotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<CapturedImage?> takeCapture({int? x, int? y, int? width, int? height}) {
    throw UnimplementedError('takeCapture() has not been implemented.');
  }

  Future<bool> startCapture({int? x, int? y, int? width, int? height, int fps = 15}) {
    throw UnimplementedError('startCapture() has not been implemented.');
  }

  Future<bool> stopCapture() {
    throw UnimplementedError('stopCapture() has not been implemented.');
  }
}
