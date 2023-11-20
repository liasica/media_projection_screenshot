# screenshot

Screenshot plugin for Android using MediaProjection API.

### Usage

```dart
import 'package:media_projection_screenshot/screenshot.dart';

final _screenshotPlugin = Screenshot();
Uint8List? result = await _screenshotPlugin.takeCapture(x: 0, y: 0, width: 1080, height: 100);
```