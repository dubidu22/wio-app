// The iPhone's privacy texts and modes (plan 063; D-344, D-346).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _value(String plist, String key) {
  final match = RegExp(
    '<key>${RegExp.escape(key)}</key>\\s*<string>([^<]*)</string>',
  ).firstMatch(plist);
  expect(match, isNotNull, reason: '$key missing');
  return match!.group(1)!;
}

void main() {
  final plist = File('ios/Runner/Info.plist').readAsStringSync();

  test('microphone and speech texts are the decided German ones (D-346)', () {
    expect(
      _value(plist, 'NSMicrophoneUsageDescription'),
      'Wio braucht das Mikrofon für Sprachnotizen zu Räumen, Fotos und '
      'Kunden. Die Aufnahme wird nur an Ihren eigenen Wio-Server gesendet.',
    );
    expect(
      _value(plist, 'NSSpeechRecognitionUsageDescription'),
      'Wio schreibt Ihre Sprachnotizen in Text um. Die Erkennung läuft nur '
      'auf diesem iPhone; die Sprache wird dafür nicht gesendet.',
    );
  });

  test('background modes are only fetch and processing: no recording in '
      'the background (D-344, D-380)', () {
    final modes = RegExp(
      '<key>UIBackgroundModes</key>\\s*<array>(.*?)</array>',
      dotAll: true,
    ).firstMatch(plist);
    expect(modes, isNotNull);
    expect(
      RegExp('<string>([^<]*)</string>')
          .allMatches(modes!.group(1)!)
          .map((m) => m.group(1))
          .toList(),
      <String>['fetch', 'processing'],
    );
  });

  test('exactly the two background tasks are allowed (D-380)', () {
    final ids = RegExp(
      '<key>BGTaskSchedulerPermittedIdentifiers</key>\\s*<array>(.*?)</array>',
      dotAll: true,
    ).firstMatch(plist);
    expect(ids, isNotNull);
    expect(
      RegExp('<string>([^<]*)</string>')
          .allMatches(ids!.group(1)!)
          .map((m) => m.group(1))
          .toList(),
      <String>['de.wiederinordnung.app.sync', 'de.wiederinordnung.app.refresh'],
    );
    final swift = File('ios/Runner/BackgroundSync.swift').readAsStringSync();
    expect(swift, contains('"de.wiederinordnung.app.sync"'));
    expect(swift, contains('"de.wiederinordnung.app.refresh"'));
  });

  test('the scene shows the shared engine, not a storyboard (D-373)', () {
    expect(plist, isNot(contains('UISceneStoryboardFile')));
    expect(plist, isNot(contains('UIMainStoryboardFile')));
    final scene = File('ios/Runner/SceneDelegate.swift').readAsStringSync();
    expect(scene, contains('FlutterViewController('));
    expect(scene, contains('engine: app.engine'));
  });

  test('every recognition request stays on the device (D-339)', () {
    final session = File('ios/Runner/VoiceSession.swift').readAsStringSync();
    final requests = 'SFSpeechAudioBufferRecognitionRequest()'
        .allMatches(session)
        .length;
    expect(requests, 1, reason: 'one place creates requests');
    expect(session, contains('requiresOnDeviceRecognition = true'));
    expect(
      Directory('ios/Runner')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.swift'))
          .where(
            (f) =>
                f.readAsStringSync().contains('SFSpeechURLRecognitionRequest'),
          ),
      isEmpty,
      reason: 'no other request type',
    );
  });
}
