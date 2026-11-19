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

  test('no background modes: no recording in the background (D-344)', () {
    expect(plist, isNot(contains('UIBackgroundModes')));
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
