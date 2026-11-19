// The voice note's file cleaning (plan 060, D-285; approval condition: no
// metadata beyond the container basics).
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/voice/m4a_clean.dart';

import '../support/m4a.dart';

void main() {
  test('udta and meta become padding; audio and size stay', () {
    final original = sampleM4a();
    final bytes = Uint8List.fromList(original);
    cleanM4a(bytes);

    expect(bytes.length, original.length);
    expect(containsBytes(bytes, ascii.encode('udta')), isFalse);
    expect(containsBytes(bytes, ascii.encode('meta')), isFalse);
    expect(containsBytes(bytes, ascii.encode('com.android')), isFalse);
    expect(containsBytes(bytes, ascii.encode('+52.5200')), isFalse);
    expect(containsBytes(bytes, ascii.encode('+48.1351')), isFalse);
    expect(containsBytes(bytes, latin1.encode('\xa9xyz')), isFalse);
    // The audio frames and the codec's own boxes are untouched.
    expect(containsBytes(bytes, sampleAudio), isTrue);
    expect(containsBytes(bytes, ascii.encode('SoundHandle')), isTrue);
    expect(containsBytes(bytes, ascii.encode('free')), isTrue);
  });

  test('creation and change times are zero', () {
    final bytes = sampleM4a();
    final time = ByteData(4)..setUint32(0, sampleTime);
    expect(containsBytes(bytes, time.buffer.asUint8List()), isTrue);
    cleanM4a(bytes);
    expect(containsBytes(bytes, time.buffer.asUint8List()), isFalse);
  });

  test('cleaning twice changes nothing more', () {
    final once = sampleM4a();
    cleanM4a(once);
    final twice = Uint8List.fromList(once);
    cleanM4a(twice);
    expect(twice, once);
  });

  test('anything but an M4A is refused', () {
    expect(
      () => cleanM4a(Uint8List.fromList(ascii.encode('not audio at all'))),
      throwsFormatException,
    );
    expect(
      () => cleanM4a(box('ftyp', ascii.encode('M4A '))),
      throwsFormatException,
    );
    final cut = sampleM4a();
    expect(
      () => cleanM4a(Uint8List.sublistView(cut, 0, cut.length - 10)),
      throwsFormatException,
    );
  });
}
