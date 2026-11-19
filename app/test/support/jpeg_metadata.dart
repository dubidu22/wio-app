import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// The marker bytes (second byte after 0xFF) of every segment before the
/// image data of the JPEG [bytes]: APP0..APP15 are 0xE0..0xEF, COM 0xFE.
List<int> jpegHeaderMarkers(Uint8List bytes) {
  if (bytes.length < 4 || bytes[0] != 0xFF || bytes[1] != 0xD8) {
    throw ArgumentError('not a JPEG');
  }
  final markers = <int>[];
  var at = 2;
  while (at + 4 <= bytes.length) {
    if (bytes[at] != 0xFF) throw ArgumentError('broken segment at $at');
    final marker = bytes[at + 1];
    markers.add(marker);
    if (marker == 0xDA) break; // start of scan: image data follows
    final length = (bytes[at + 2] << 8) | bytes[at + 3];
    at += 2 + length;
  }
  return markers;
}

/// Metadata segments: APP1..APP15 (EXIF, XMP, ICC, Photoshop/IPTC, ...) and
/// comments. APP0 (JFIF) holds only the format version and pixel density.
bool isMetadataMarker(int marker) =>
    (marker >= 0xE1 && marker <= 0xEF) || marker == 0xFE;

/// A camera-like shot of [width] x [height] with everything a phone may
/// write: EXIF with an orientation, a GPS position, a maker note and a
/// device name, plus an XMP segment and a comment. [shade] makes shots
/// differ.
Uint8List shotWithLocation({
  int width = 3840,
  int height = 2160,
  int orientation = 1,
  int shade = 128,
}) {
  final picture = img.Image(width: width, height: height);
  for (final pixel in picture) {
    pixel
      ..r = pixel.x * 255 ~/ width
      ..g = pixel.y * 255 ~/ height
      ..b = shade;
  }
  picture.exif.imageIfd
    ..orientation = orientation
    ..['Make'] = img.IfdValueAscii('Beispielhersteller')
    ..['Model'] = img.IfdValueAscii('Beispieltelefon 7');
  picture.exif.exifIfd[0x927c] = img.IfdValueUndefined.list(
    Uint8List.fromList('MAKERNOTE-SERIAL-12345'.codeUnits),
  );
  picture.exif.gpsIfd
    ..[0x0001] = img.IfdValueAscii('N')
    ..[0x0002] = img.IfdValueRational.list(<img.Rational>[
      img.Rational(52, 1),
      img.Rational(31, 1),
      img.Rational(1234, 100),
    ])
    ..[0x0003] = img.IfdValueAscii('E')
    ..[0x0004] = img.IfdValueRational.list(<img.Rational>[
      img.Rational(13, 1),
      img.Rational(24, 1),
      img.Rational(5678, 100),
    ]);
  final encoded = img.encodeJpg(picture, quality: 70);
  return _insertAfterSoi(encoded, <List<int>>[
    _segment(0xE1, <int>[
      ...'http://ns.adobe.com/xap/1.0/\u0000'.codeUnits,
      ...'<x:xmpmeta><exif:GPSLatitude>52,31N</exif:GPSLatitude></x:xmpmeta>'
          .codeUnits,
    ]),
    _segment(0xFE, 'Aufgenommen in der Beispielstrasse 1'.codeUnits),
  ]);
}

List<int> _segment(int marker, List<int> payload) {
  final length = payload.length + 2;
  return <int>[0xFF, marker, length >> 8, length & 0xFF, ...payload];
}

Uint8List _insertAfterSoi(Uint8List jpeg, List<List<int>> segments) {
  return Uint8List.fromList(<int>[
    0xFF,
    0xD8,
    for (final segment in segments) ...segment,
    ...jpeg.sublist(2),
  ]);
}
