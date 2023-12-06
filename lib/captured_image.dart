import 'dart:typed_data';

class CapturedImage {
  Uint8List bytes;
  Uint8List nv21;
  int width;
  int height;
  int rowBytes;
  int pixelStride;
  int rowStride;
  String format;

  CapturedImage({
    required this.bytes,
    required this.nv21,
    required this.width,
    required this.height,
    required this.rowBytes,
    required this.pixelStride,
    required this.rowStride,
    required this.format,
  });

  factory CapturedImage.fromMap(Map<String, dynamic> map) {
    return CapturedImage(
      bytes: map['bytes'],
      nv21: map['nv21'],
      width: map['width'],
      height: map['height'],
      rowBytes: map['rowBytes'],
      pixelStride: map['pixelStride'],
      rowStride: map['rowStride'],
      format: map['format'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bytes': bytes,
      'nv21': nv21,
      'width': width,
      'height': height,
      'rowBytes': rowBytes,
      'format': format,
      'pixelStride': pixelStride,
      'rowStride': rowStride,
    };
  }

  @override
  String toString() =>
      "ScreenshotImage(bytes: [${bytes.length} BYTES...], nv21: [${nv21.length} BYTES...], width: $width, height: $height, rowBytes: $rowBytes, format: $format, pixelStride: $pixelStride, rowStride: $rowStride)";

  @override
  int get hashCode => Object.hash(bytes, nv21, width, height, rowBytes, format, pixelStride, rowStride);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CapturedImage &&
          runtimeType == other.runtimeType &&
          bytes == other.bytes &&
          nv21 == other.nv21 &&
          width == other.width &&
          height == other.height &&
          rowBytes == other.rowBytes &&
          format == other.format &&
          pixelStride == other.pixelStride &&
          rowStride == other.rowStride;
}
