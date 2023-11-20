package com.liasica.screenshot

import android.annotation.SuppressLint
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Base64
import im.zego.media_projection_creator.MediaProjectionCreatorCallback
import im.zego.media_projection_creator.RequestMediaProjectionPermissionManager
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream

/** ScreenshotPlugin */
class ScreenshotPlugin : FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private var mediaProjection: MediaProjection? = null

  companion object {
    const val LOG_TAG = "SCREENSHOT"
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "screenshot")
    channel.setMethodCallHandler(this)

    RequestMediaProjectionPermissionManager.getInstance().setRequestPermissionCallback(mediaProjectionCreatorCallback);
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "takeCapture" -> {
        takeCapture(call, result)
      }

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private val mediaProjectionCreatorCallback = MediaProjectionCreatorCallback { projection, errorCode ->
    when (errorCode) {
      RequestMediaProjectionPermissionManager.ERROR_CODE_SUCCEED -> {
        Log.i(LOG_TAG, "Create media projection succeeded!")
        mediaProjection = projection
      }

      RequestMediaProjectionPermissionManager.ERROR_CODE_FAILED_USER_CANCELED -> {
        Log.e(LOG_TAG, "Create media projection failed because can not get permission")
      }

      RequestMediaProjectionPermissionManager.ERROR_CODE_FAILED_SYSTEM_VERSION_TOO_LOW -> {
        Log.e(LOG_TAG, "Create media projection failed because system api level is lower than 21")
      }
    }
  }

  @SuppressLint("WrongConstant")
  private fun takeCapture(call: MethodCall, result: Result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
      result.error(LOG_TAG, "Create media projection failed because system api level is lower than 21", null)
      return
    }

    if (mediaProjection == null) {
      result.error(LOG_TAG, "Must request permission before take capture", null)
      return
    }

    val metrics = Resources.getSystem().displayMetrics
    val width = metrics.widthPixels
    val height = metrics.heightPixels

    val imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)

    val virtualDisplay = mediaProjection?.createVirtualDisplay(
      "ScreenCapture",
      width,
      height,
      1,
      DisplayManager.VIRTUAL_DISPLAY_FLAG_PUBLIC,
      imageReader.surface,
      null,
      null,
    )

    Handler(Looper.getMainLooper()).postDelayed({
      val image = imageReader.acquireLatestImage()

      val planes = image.planes
      val buffer = planes[0].buffer
      val pixelStride = planes[0].pixelStride
      val rowStride = planes[0].rowStride
      val rowPadding = rowStride - pixelStride * width
      val padding = rowPadding / pixelStride

      val bitmap = Bitmap.createBitmap(width + padding, height, Bitmap.Config.ARGB_8888)
      bitmap.copyPixelsFromBuffer(buffer)

      image.close()
      virtualDisplay?.release()

      val region = call.arguments as Map<*, *>
      val x = region["x"] as Int + padding / 2
      val y = region["y"] as Int
      val w = region["width"] as Int
      val h = region["height"] as Int

      val cropped = bitmap.crop(x, y, w, h)
      val outputStream = ByteArrayOutputStream()
      cropped.compress(Bitmap.CompressFormat.PNG, 100, outputStream)

      val byteArray = outputStream.toByteArray()
      val b64 = "data:image/png;base64," + Base64.encodeToString(byteArray, Base64.NO_WRAP)
      Log.i(LOG_TAG, "base64 = $b64")

      result.success(byteArray)
    }, 100)
  }

  private fun Bitmap.crop(x: Int, y: Int, width: Int, height: Int): Bitmap {
    return Bitmap.createBitmap(this, x, y, width, height, null, true)
  }
}
