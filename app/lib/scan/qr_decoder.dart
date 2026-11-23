import 'dart:convert';
import 'dart:typed_data';

import 'package:zxing2/qrcode.dart';

/// Reads one QR code from a camera frame's brightness plane (D-463).
///
/// [y] holds [height] rows of [stride] bytes each, of which the first
/// [width] are the picture (the Y plane of a YUV 4:2:0 frame). Returns the
/// code's text unchanged (D-51, D-466), or null when the frame has no
/// readable QR code. Pure Dart, no Flutter: runs in the scanner's isolate
/// and in plain unit tests.
String? decodeQr(Uint8List y, int width, int height, int stride) {
  if (width <= 0 || height <= 0 || stride < width) return null;
  if (y.length < stride * (height - 1) + width) return null;
  try {
    final result = QRCodeReader().decode(
      BinaryBitmap(HybridBinarizer(BrightnessPlane(y, width, height, stride))),
    );
    final text = _repaired(result);
    return text == null || text.isEmpty ? null : text;
  } on ReaderException {
    return null;
  } on ArgumentError {
    // Also RangeError: the port can index past a damaged pattern; such a
    // frame is a frame without a code.
    return null;
  }
}

/// zxing2 0.2.4 keeps the bytes of a byte-mode segment as signed values
/// and so turns every byte over 127 into U+FFFD. When the whole text is one
/// such segment, its bytes are decoded again here: UTF-8 when they are
/// valid UTF-8, else ISO-8859-1. A mixed text that cannot be rebuilt is
/// not taken (null), so no code with lost characters is ever stored.
String? _repaired(Result result) {
  final text = result.text;
  if (!text.contains('\uFFFD')) return text;
  final segments = result.resultMetadata[ResultMetadataType.byteSegments];
  if (segments is! List || segments.length != 1) return null;
  final segment = segments.single;
  if (segment is! Int8List || segment.length != text.length) return null;
  final bytes = Uint8List.fromList(segment);
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return latin1.decode(bytes);
  }
}

/// A brightness plane with a row stride, as zxing2 reads it. zxing2 does
/// not export its own YUV source, so the app has this small one.
class BrightnessPlane extends LuminanceSource {
  BrightnessPlane(this._bytes, int width, int height, this._stride)
    : super(width, height);

  final Uint8List _bytes;
  final int _stride;

  @override
  Int8List getRow(int y, Int8List? row) {
    final out = row == null || row.length < width ? Int8List(width) : row;
    final start = y * _stride;
    out.setRange(0, width, Int8List.sublistView(_bytes, start, start + width));
    return out;
  }

  @override
  Int8List getMatrix() {
    final out = Int8List(width * height);
    for (var row = 0; row < height; row++) {
      final start = row * _stride;
      out.setRange(
        row * width,
        (row + 1) * width,
        Int8List.sublistView(_bytes, start, start + width),
      );
    }
    return out;
  }
}
