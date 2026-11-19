import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// D-272: the camera asks for the camera only. The camera plugin's own
/// manifest adds shared storage; the app removes it, and iOS explains the
/// camera in German. D-294: the voice note declares the microphone itself.
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();
  final plist = File('ios/Runner/Info.plist').readAsStringSync();

  String element(String name) =>
      RegExp('<(uses-permission|uses-feature)\\s+android:name="$name"[^>]*/>')
          .firstMatch(manifest)![0]!;

  test('shared storage is removed', () {
    expect(
      element('android.permission.WRITE_EXTERNAL_STORAGE'),
      contains('tools:node="remove"'),
    );
  });

  test('the app declares the microphone itself, and nothing for the '
      'background (D-291, D-294)', () {
    expect(
      element('android.permission.RECORD_AUDIO'),
      isNot(contains('tools:node')),
    );
    expect(manifest, isNot(contains('FOREGROUND_SERVICE')));
    expect(manifest, isNot(contains('MODIFY_AUDIO_SETTINGS')));
  });

  test('a camera is not required to install the app', () {
    final feature = element('android.hardware.camera.any');
    expect(feature, contains('android:required="false"'));
    expect(feature, contains('tools:node="replace"'));
  });

  test('iOS explains the camera in German', () {
    final match = RegExp(
      '<key>NSCameraUsageDescription</key>\\s*<string>([^<]+)</string>',
    ).firstMatch(plist);
    expect(match, isNotNull);
    expect(match![1], contains('Kamera'));
    expect(match[1], contains('Fotos'));
  });
}
