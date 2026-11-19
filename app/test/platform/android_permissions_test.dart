import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// D-272: the camera asks for the camera only. The camera plugin's own
/// manifest adds shared storage; the app removes it, and iOS explains the
/// camera in German. D-294: the voice note declares the microphone itself.
/// D-313, D-317: the merger's implied READ_EXTERNAL_STORAGE is removed, and
/// no camera or microphone is required to install the app. The built APK's
/// whole list is checked in CI against android/permissions.txt (D-310).
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();
  final plist = File('ios/Runner/Info.plist').readAsStringSync();

  String element(String name) =>
      RegExp('<(uses-permission|uses-feature)\\s+android:name="$name"[^>]*/>')
          .firstMatch(manifest)![0]!;

  test('shared storage is removed, reading too (D-313)', () {
    expect(
      element('android.permission.WRITE_EXTERNAL_STORAGE'),
      contains('tools:node="remove"'),
    );
    expect(
      element('android.permission.READ_EXTERNAL_STORAGE'),
      contains('tools:node="remove"'),
    );
  });

  test('the app declares the microphone itself, and no foreground service '
      '(D-291, D-294, D-379)', () {
    expect(
      element('android.permission.RECORD_AUDIO'),
      isNot(contains('tools:node')),
    );
    expect(manifest, isNot(contains('MODIFY_AUDIO_SETTINGS')));
    // WorkManager brings FOREGROUND_SERVICE and its service; both go.
    expect(
      element('android.permission.FOREGROUND_SERVICE'),
      contains('tools:node="remove"'),
    );
    expect(
      RegExp('android:name="android.permission.FOREGROUND_SERVICE_[A-Z_]+"')
          .hasMatch(manifest),
      isFalse,
    );
    expect(
      RegExp(
        '<service\\s+android:name="androidx.work.impl.foreground.'
        'SystemForegroundService"\\s+tools:node="remove"/>',
      ).hasMatch(manifest),
      isTrue,
    );
  });

  test('background sync permissions are in the allow-list (D-379)', () {
    final allowed = File('android/permissions.txt').readAsLinesSync();
    for (final name in <String>[
      'android.permission.WAKE_LOCK',
      'android.permission.RECEIVE_BOOT_COMPLETED',
    ]) {
      expect(allowed, contains('uses-permission $name'), reason: name);
    }
    expect(
      allowed.where(
        (l) =>
            l ==
            'uses-permission android.permission.'
                'FOREGROUND_SERVICE',
      ),
      isEmpty,
    );
  });

  test('a camera is not required to install the app', () {
    final feature = element('android.hardware.camera.any');
    expect(feature, contains('android:required="false"'));
    expect(feature, contains('tools:node="replace"'));
  });

  test('no camera or microphone is required to install the app (D-317)', () {
    for (final name in <String>[
      'android.hardware.camera',
      'android.hardware.camera.autofocus',
      'android.hardware.microphone',
    ]) {
      expect(element(name), contains('android:required="false"'), reason: name);
    }
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
