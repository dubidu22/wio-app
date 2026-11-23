import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/scan/qr_decoder.dart';
import 'package:zxing2/qrcode.dart';

/// A camera-like brightness plane ([width] x [height], rows of [stride]
/// bytes, light noisy paper) with [text] as a QR code at [scale] px per
/// module, top left at ([left], [top]).
Uint8List frameWith(
  String text, {
  int width = 640,
  int height = 480,
  int? stride,
  int scale = 6,
  int left = 120,
  int top = 60,
  CharacterSetECI? charset,
}) {
  final rowBytes = stride ?? width;
  final random = Random(7);
  final y = Uint8List(rowBytes * height);
  for (var i = 0; i < y.length; i++) {
    y[i] = 150 + random.nextInt(40);
  }
  final hints = EncodeHints();
  if (charset != null) hints.put(EncodeHintType.characterSet, charset);
  final matrix = Encoder.encode(
    text,
    ErrorCorrectionLevel.m,
    hints: hints,
  ).matrix!;
  for (var my = 0; my < matrix.height; my++) {
    for (var mx = 0; mx < matrix.width; mx++) {
      if (matrix.get(mx, my) != 1) continue;
      for (var dy = 0; dy < scale; dy++) {
        for (var dx = 0; dx < scale; dx++) {
          y[(top + my * scale + dy) * rowBytes + left + mx * scale + dx] =
              30 + random.nextInt(40);
        }
      }
    }
  }
  return y;
}

void main() {
  test('reads a label code unchanged (D-51)', () {
    expect(
      decodeQr(frameWith('WIO-7F3K-2291'), 640, 480, 640),
      'WIO-7F3K-2291',
    );
  });

  test('keeps case, spaces and symbols as they are', () {
    for (final code in <String>[
      ' Box 1 ',
      'abc-ABC',
      'https://x.example/k?id=7',
    ]) {
      expect(decodeQr(frameWith(code), 640, 480, 640), code);
    }
  });

  test('umlauts come back whole (zxing2 byte bug worked around)', () {
    for (final charset in <CharacterSetECI?>[
      CharacterSetECI.UTF8,
      CharacterSetECI.ISO8859_1,
      null, // ISO-8859-1 without a mark, the QR default
    ]) {
      final frame = frameWith('Küche-1', charset: charset);
      expect(decodeQr(frame, 640, 480, 640), 'Küche-1', reason: '$charset');
    }
  });

  test('rows longer than the picture (stride) are read right', () {
    final frame = frameWith('WIO-0042', stride: 704);
    expect(decodeQr(frame, 640, 480, 704), 'WIO-0042');
  });

  test('a long code is returned whole; the screen decides (D-469)', () {
    final code = 'A' * 300;
    final frame = frameWith(
      code,
      width: 1280,
      height: 720,
      scale: 6,
      left: 200,
    );
    final read = decodeQr(frame, 1280, 720, 1280);
    expect(read, code);
    expect(utf8.encode(read!).length, greaterThan(255));
  });

  test('a frame without a code is null', () {
    final blank = Uint8List(640 * 480)..fillRange(0, 640 * 480, 160);
    expect(decodeQr(blank, 640, 480, 640), isNull);
    final noise = Uint8List.fromList(
      List<int>.generate(640 * 480, (i) => Random(i).nextInt(256)),
    );
    expect(decodeQr(noise, 640, 480, 640), isNull);
  });

  test('a frame too short for its size is null, not an error', () {
    expect(decodeQr(Uint8List(100), 640, 480, 640), isNull);
    expect(decodeQr(Uint8List(0), 0, 0, 0), isNull);
    expect(decodeQr(frameWith('X'), 640, 480, 320), isNull);
  });
}
