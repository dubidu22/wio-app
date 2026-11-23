import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/scan/camera_qr_scanner.dart';

BrightnessFrame _frame() => (y: Uint8List(16), width: 4, height: 4, stride: 4);

void main() {
  test(
    'one frame in flight: frames while one is decoded are dropped',
    () async {
      var calls = 0;
      var answer = Completer<String?>();
      final scanner = CameraQrScanner(
        decode: (frame) {
          calls++;
          return answer.future;
        },
      );
      final codes = <String>[];
      final sub = scanner.codes.listen(codes.add);

      scanner
        ..onFrame(_frame())
        ..onFrame(_frame())
        ..onFrame(_frame());
      expect(calls, 1);

      answer.complete(null);
      await pumpEventQueue();
      answer = Completer<String?>();
      scanner.onFrame(_frame());
      expect(calls, 2, reason: 'the next frame after the decode is read');

      answer.complete('WIO-1');
      await pumpEventQueue();
      expect(codes, <String>['WIO-1']);
      await sub.cancel();
    },
  );

  test(
    'a code decoded after close is not emitted, and no frame is taken',
    () async {
      var calls = 0;
      final answer = Completer<String?>();
      final scanner = CameraQrScanner(
        decode: (frame) {
          calls++;
          return answer.future;
        },
      );
      final codes = <String>[];
      final sub = scanner.codes.listen(codes.add);

      scanner.onFrame(_frame());
      await scanner.close();
      answer.complete('WIO-2');
      await pumpEventQueue();
      expect(codes, isEmpty);

      scanner.onFrame(_frame());
      expect(calls, 1);
      await sub.cancel();
    },
  );

  test('a decoder error counts as a frame without a code', () async {
    var calls = 0;
    final scanner = CameraQrScanner(
      decode: (frame) async {
        calls++;
        if (calls == 1) throw StateError('bad frame');
        return 'WIO-3';
      },
    );
    final codes = <String>[];
    final sub = scanner.codes.listen(codes.add);
    scanner.onFrame(_frame());
    await pumpEventQueue();
    scanner.onFrame(_frame());
    await pumpEventQueue();
    expect(codes, <String>['WIO-3']);
    await sub.cancel();
  });
}
