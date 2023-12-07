# screenshot

Screenshot plugin for Android using MediaProjection API.

### Usage

```dart
import 'package:media_projection_screenshot/media_projection_screenshot.dart';

final _screenshotPlugin = MediaProjectionScreenshot();
final result = await _screenshotPlugin.takeCapture(x: 0, y: 0, width: 1080, height: 100);
```

### Refers

- [Android 音视频开发——录屏直播](https://blog.51cto.com/u_15375308/3997338)
- [1对1直播源码开发，Android获取实时屏幕画面](https://cloud.tencent.com/developer/article/1837042)
- [Android实现截屏功能](https://www.jb51.net/article/217134.htm)
- [Android录屏与传输](https://xhrong.github.io/2019/10/05/Android%E5%BD%95%E5%B1%8F%E4%B8%8E%E4%BC%A0%E8%BE%93/)
- [Android PC投屏简单尝试- 自定义协议章(Socket+Bitmap)](https://www.jianshu.com/p/ce37330365f2)