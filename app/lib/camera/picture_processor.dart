import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Longest side of a stored picture in pixels (Q2, D-219, D-267).
const int maxLongSidePx = 2560;

/// JPEG quality of a stored picture (Q2, D-267).
const int jpegQuality = 85;

/// A picture made fit for storing: a new JPEG with no metadata at all.
class PreparedJpeg {
  const PreparedJpeg({
    required this.bytes,
    required this.widthPx,
    required this.heightPx,
  });

  final Uint8List bytes;
  final int widthPx;
  final int heightPx;
}

/// Thrown when a shot is not an image the app can read.
class UnreadablePicture implements Exception {
  const UnreadablePicture();

  @override
  String toString() => 'UnreadablePicture';
}

/// Turns a camera shot into the file the app stores (D-267): decodes it,
/// turns it upright from its EXIF orientation, shrinks the long side to at
/// most [maxLongSidePx] (never larger) and encodes a new JPEG from the
/// pixels only. EXIF (including location), XMP, ICC profiles, comments and
/// maker notes are not copied, so none of them can leave the device.
PreparedJpeg preparePictureBytes(Uint8List shot) {
  final decoded = img.decodeImage(shot);
  if (decoded == null) {
    throw const UnreadablePicture();
  }
  var picture = img.bakeOrientation(decoded);
  final longSide = picture.width > picture.height
      ? picture.width
      : picture.height;
  if (longSide > maxLongSidePx) {
    picture = picture.width >= picture.height
        ? img.copyResize(
            picture,
            width: maxLongSidePx,
            interpolation: img.Interpolation.average,
          )
        : img.copyResize(
            picture,
            height: maxLongSidePx,
            interpolation: img.Interpolation.average,
          );
  }
  // Pixels only: copies keep the source's metadata, and the encoder writes
  // whatever metadata the image still carries.
  final clean = img.Image.fromBytes(
    width: picture.width,
    height: picture.height,
    bytes: picture.convert(format: img.Format.uint8, numChannels: 3).buffer,
    numChannels: 3,
  );
  return PreparedJpeg(
    bytes: img.encodeJpg(clean, quality: jpegQuality),
    widthPx: clean.width,
    heightPx: clean.height,
  );
}

/// Turns a shot into the file the app stores.
typedef PictureProcessor = Future<PreparedJpeg> Function(Uint8List shot);

/// [preparePictureBytes] off the UI isolate (D-267).
Future<PreparedJpeg> preparePicture(Uint8List shot) =>
    compute(preparePictureBytes, shot);
