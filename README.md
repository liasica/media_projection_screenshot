# screenshot

Screenshot plugin for Android using MediaProjection API.

### Usage

```dart
import 'package:media_projection_screenshot/media_projection_screenshot.dart';

final _screenshotPlugin = MediaProjectionScreenshot();
final result = await _screenshotPlugin.takeCapture(x: 0, y: 0, width: 1080, height: 100);
```