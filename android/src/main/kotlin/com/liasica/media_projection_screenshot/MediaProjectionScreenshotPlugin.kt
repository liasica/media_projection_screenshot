package com.liasica.media_projection_screenshot

import android.annotation.SuppressLint
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.projection.MediaProjection
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.os.Message
import android.util.Base64
import android.view.Surface
import androidx.annotation.RequiresApi
import im.zego.media_projection_creator.MediaProjectionCreatorCallback
import im.zego.media_projection_creator.RequestMediaProjectionPermissionManager
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream


/** MediaProjectionScreenshotPlugin */
class MediaProjectionScreenshotPlugin : FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private var mediaProjection: MediaProjection? = null

  private var virtualDisplay: VirtualDisplay? = null
  private var surface: Surface? = null
  private var isCapturing: Boolean = false
  private var codec: MediaCodec? = null
  private var handlerThread: HandlerThread? = null
  private var handler: Handler? = null

  companion object {
    const val LOG_TAG = "MP_SCREENSHOT"
    const val CAPTURE_SINGLE = "MP_CAPTURE_SINGLE"
    const val CAPTURE_CONSEQUENT = "MP_CAPTURE_CONSEQUENT"
    const val CAPTURE_CONSEQUENT_HANDLER_THREAD = "MP_CAPTURE_CONSEQUENT_HANDLER_THREAD"
  }

  @RequiresApi(Build.VERSION_CODES.O)
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "media_projection_screenshot")
    channel.setMethodCallHandler(this)

    RequestMediaProjectionPermissionManager.getInstance().setRequestPermissionCallback(mediaProjectionCreatorCallback);
  }

  @RequiresApi(Build.VERSION_CODES.O)
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "takeCapture" -> {
        takeCapture(call, result)
      }
      "startCapture" -> {
        startCapture(call, result)
      }
      "stopCapture" -> {
        stopCapture(call, result)
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

  private fun stopCapture(call: MethodCall, result: Result) {
    if (!isCapturing) {
      result.error(LOG_TAG, "Screen capture is not start", null)
      return
    }

    isCapturing = false

    virtualDisplay?.release()
    virtualDisplay = null

    surface?.release()
    surface = null

    codec?.release()
    codec = null

    handlerThread?.quit()
    handlerThread = null

    handler = null
  }

  @RequiresApi(Build.VERSION_CODES.O)
  private fun startCapture(call: MethodCall, result: Result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
      result.error(LOG_TAG, "Create media projection failed because system api level is lower than 21", null)
      return
    }

    if (mediaProjection == null) {
      result.error(LOG_TAG, "Must request permission before take capture", null)
      return
    }

    if (isCapturing) {
      result.error(LOG_TAG, "Screen capture has started", null)
      return
    }

    isCapturing = true

    val metrics = Resources.getSystem().displayMetrics
    val width = metrics.widthPixels
    val height = metrics.heightPixels

    // 配置 MediaCodec
    val mediaFormat = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, width, height)
    // 颜色格式
    mediaFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface)
    mediaFormat.setInteger(MediaFormat.KEY_BIT_RATE, 400_000)
    mediaFormat.setInteger(MediaFormat.KEY_FRAME_RATE, 15)
    // 设置触发关键帧的时间间隔为 2 s
    mediaFormat.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 2)

    codec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
    codec!!.configure(mediaFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)

    surface = codec!!.createInputSurface()

    handlerThread = HandlerThread(CAPTURE_CONSEQUENT_HANDLER_THREAD)
    handlerThread!!.start()

    handler = Handler(handlerThread!!.looper)

    virtualDisplay = mediaProjection?.createVirtualDisplay(
      CAPTURE_CONSEQUENT,
      width,
      height,
      1,
      DisplayManager.VIRTUAL_DISPLAY_FLAG_PUBLIC,
      surface,
      null,
      handler,
    )

    codec!!.start()
    Log.i(LOG_TAG, "Screen capture started")
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

    val imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 1)

    val mVirtualDisplay = mediaProjection?.createVirtualDisplay(
      CAPTURE_SINGLE,
      width,
      height,
      1,
      DisplayManager.VIRTUAL_DISPLAY_FLAG_PUBLIC,
      imageReader.surface,
      null,
      null,
    )

    Handler(Looper.getMainLooper()).postDelayed({
      val image = imageReader.acquireLatestImage() ?: return@postDelayed

      val planes = image.planes
      val buffer = planes[0].buffer
      val pixelStride = planes[0].pixelStride
      val rowStride = planes[0].rowStride
      val rowPadding = rowStride - pixelStride * width
      val padding = rowPadding / pixelStride

      var bitmap = Bitmap.createBitmap(width + padding, height, Bitmap.Config.ARGB_8888)
      bitmap.copyPixelsFromBuffer(buffer)

      image.close()
      mVirtualDisplay?.release()

      val region = call.arguments as Map<*, *>?
      region?.let {
        val x = it["x"] as Int + padding / 2
        val y = it["y"] as Int
        val w = it["width"] as Int
        val h = it["height"] as Int

        bitmap = bitmap.crop(x, y, w, h)
      }

      val outputStream = ByteArrayOutputStream()
      bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)

      val byteArray = outputStream.toByteArray()
      val b64 = "data:image/png;base64," + Base64.encodeToString(byteArray, Base64.NO_WRAP)
      // Log.i(LOG_TAG, "base64 = $b64")

      result.success(
        mapOf(
          "bytes" to byteArray,
          "width" to bitmap.width,
          "height" to bitmap.height,
          "rowBytes" to bitmap.rowBytes,
          "format" to Bitmap.Config.ARGB_8888.toString(),
          "pixelStride" to pixelStride,
          "rowStride" to rowStride,
          "nv21" to getYV12(bitmap.width, bitmap.height, bitmap),
          "base64" to b64,
        )
      )
    }, 100)
  }

  private fun Bitmap.crop(x: Int, y: Int, width: Int, height: Int): Bitmap {
    return Bitmap.createBitmap(this, x, y, width, height, null, true)
  }

  private fun getYV12(inputWidth: Int, inputHeight: Int, scaled: Bitmap): ByteArray {
    val argb = IntArray(inputWidth * inputHeight)
    scaled.getPixels(argb, 0, inputWidth, 0, 0, inputWidth, inputHeight)
    val yuv = ByteArray(inputWidth * inputHeight * 3 / 2)
    encodeYV12(yuv, argb, inputWidth, inputHeight)
    scaled.recycle()
    return yuv
  }

  private fun encodeYV12(yuv420sp: ByteArray, argb: IntArray, width: Int, height: Int) {
    val frameSize = width * height
    var yIndex = 0
    var uIndex = frameSize
    var vIndex = frameSize + frameSize / 4
    var a: Int
    var r: Int
    var g: Int
    var b: Int
    var y: Int
    var u: Int
    var v: Int
    var index = 0
    for (j in 0 until height) {
      for (i in 0 until width) {
        a = argb[index] and -0x1000000 shr 24 // a is not used obviously
        r = argb[index] and 0xff0000 shr 16
        g = argb[index] and 0xff00 shr 8
        b = argb[index] and 0xff shr 0

        // well known RGB to YUV algorithm
        y = (66 * r + 129 * g + 25 * b + 128 shr 8) + 16
        u = (-38 * r - 74 * g + 112 * b + 128 shr 8) + 128
        v = (112 * r - 94 * g - 18 * b + 128 shr 8) + 128

        // YV12 has a plane of Y and two chroma plans (U, V) planes each sampled by a factor of 2
        //    meaning for every 4 Y pixels there are 1 V and 1 U.  Note the sampling is every other
        //    pixel AND every other scanline.
        yuv420sp[yIndex++] = (if (y < 0) 0 else if (y > 255) 255 else y).toByte()
        if (j % 2 == 0 && index % 2 == 0) {
          yuv420sp[uIndex++] = (if (v < 0) 0 else if (v > 255) 255 else v).toByte()
          yuv420sp[vIndex++] = (if (u < 0) 0 else if (u > 255) 255 else u).toByte()
        }
        index++
      }
    }
  }
}
