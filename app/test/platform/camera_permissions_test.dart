import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// D-272: the camera asks for the camera only. The camera plugin's own
/// manifest adds the microphone and shared storage; the app removes both,
/// and iOS explains the camera in German.
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();
  final plist = File('ios/Runner/Info.plist').readAsStringSync();

  String element(String name) =>
      RegExp('<(uses-permission|uses-feature)\\s+android:name="$name"[^>]*/>')
          .firstMatch(manifest)![0]!;

  test('the microphone and shared storage are removed', () {
    for (final permission in <String>[
      'android.permission.RECORD_AUDIO',
      'android.permission.WRITE_EXTERNAL_STORAGE',
    ]) {
      expect(element(permission), contains('tools:node="remove"'));
    }
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
