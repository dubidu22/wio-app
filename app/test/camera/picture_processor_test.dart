import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:wio_app/camera/picture_processor.dart';

import '../support/jpeg_metadata.dart';

void main() {
  group('preparePictureBytes (D-267)', () {
    late Uint8List shot;

    setUpAll(() {
      shot = shotWithLocation(orientation: 6);
    });

    test('the test shot really carries location and other metadata', () {
      final markers = jpegHeaderMarkers(shot);
      expect(markers.where(isMetadataMarker), isNotEmpty);
      final exif = img.decodeJpgExif(shot)!;
      expect(exif.gpsIfd.isEmpty, isFalse);
      expect(exif.imageIfd.orientation, 6);
    });

    test(
      'writes no EXIF, GPS, XMP or comment and turns the picture upright',
      () {
        final prepared = preparePictureBytes(shot);

        expect(
          jpegHeaderMarkers(prepared.bytes).where(isMetadataMarker),
          isEmpty,
        );
        expect(_contains(prepared.bytes, 'Exif'.codeUnits), isFalse);
        expect(_contains(prepared.bytes, 'xmpmeta'.codeUnits), isFalse);
        expect(_contains(prepared.bytes, 'Beispiel'.codeUnits), isFalse);
        expect(_contains(prepared.bytes, 'MAKERNOTE'.codeUnits), isFalse);

        expect(img.decodeJpgExif(prepared.bytes)?.isEmpty ?? true, isTrue);
        final decoded = img.decodeJpg(prepared.bytes)!;
        // Orientation 6 = turned 90 degrees: the portrait picture is upright.
        expect((prepared.widthPx, prepared.heightPx), (1440, 2560));
        expect((decoded.width, decoded.height), (1440, 2560));
        // Turned clockwise, not the other way (PR 69 N1): the source's
        // bottom-left corner (no red, full green) is now top left, and its
        // top-left corner (no red, no green) is now top right.
        final topLeft = decoded.getPixel(2, 2);
        final topRight = decoded.getPixel(decoded.width - 3, 2);
        expect(topLeft.r, lessThan(30));
        expect(topLeft.g, greaterThan(225));
        expect(topRight.r, lessThan(30));
        expect(topRight.g, lessThan(30));
      },
    );

    test('shrinks a landscape shot to 2560 on its long side', () {
      final prepared = preparePictureBytes(shotWithLocation());
      expect((prepared.widthPx, prepared.heightPx), (2560, 1440));
    });

    test('never enlarges a small shot but still strips it', () {
      final prepared = preparePictureBytes(
        shotWithLocation(width: 1200, height: 900),
      );
      expect((prepared.widthPx, prepared.heightPx), (1200, 900));
      expect(
        jpegHeaderMarkers(prepared.bytes).where(isMetadataMarker),
        isEmpty,
      );
    });

    test('refuses bytes that are no picture', () {
      expect(
        () => preparePictureBytes(Uint8List.fromList('kein Bild'.codeUnits)),
        throwsA(isA<UnreadablePicture>()),
      );
    });
  });
}

bool _contains(Uint8List haystack, List<int> needle) {
  outer:
  for (var i = 0; i + needle.length <= haystack.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}
