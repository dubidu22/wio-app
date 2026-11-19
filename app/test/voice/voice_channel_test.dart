// The shared Dart side of the native channels on iOS (plan 063, T4/T5;
// D-337, D-340, D-343, D-349, D-350).
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/notes/notes_providers.dart';
import 'package:wio_app/voice/voice_providers.dart';
import 'package:wio_app/voice/voice_recorder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('wio/voice');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  Future<void> fromPhone(String method, [Object? arguments]) async {
    final data = const StandardMethodCodec().encodeMethodCall(
      MethodCall(method, arguments),
    );
    await messenger.handlePlatformMessage('wio/voice', data, (_) {});
  }

  test(
    'onInterrupted and speechRefused reach the screen (D-340, D-343)',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async => null);
      final recorder = ChannelVoiceRecorder(channel);
      final statuses = <TranscriptStatus>[];
      var interrupted = 0;
      await recorder.start(
        '/tmp/a.m4a',
        onTranscript: statuses.add,
        onPartial: (_) {},
        onInterrupted: () => interrupted++,
      );
      await fromPhone('onTranscription', 'speechRefused');
      await fromPhone('onInterrupted');
      expect(statuses, <TranscriptStatus>[TranscriptStatus.speechRefused]);
      expect(interrupted, 1);

      messenger.setMockMethodCallHandler(
        channel,
        (call) async => <String, Object?>{'millis': 4200, 'transcript': ''},
      );
      final take = await recorder.stop();
      expect(take.length, const Duration(milliseconds: 4200));
      expect(take.error, isNull, reason: 'iOS leaves error out when none');
      await fromPhone('onInterrupted');
      expect(interrupted, 1, reason: 'no callback after stop');
    },
  );

  test('voice notes record and play on Android and iOS, not elsewhere '
      '(D-350)', () {
    final expected = <TargetPlatform, bool>{
      TargetPlatform.android: true,
      TargetPlatform.iOS: true,
      TargetPlatform.linux: false,
      TargetPlatform.macOS: false,
    };
    for (final MapEntry(key: platform, value: yes) in expected.entries) {
      debugDefaultTargetPlatformOverride = platform;
      try {
        final container = ProviderContainer(
          overrides: [
            mediaStoreProvider.overrideWithValue(
              MediaStore(() async => '/tmp/wio-test'),
            ),
          ],
        );
        addTearDown(container.dispose);
        expect(
          container.read(canRecordVoiceProvider),
          yes,
          reason: '$platform',
        );
        expect(container.read(canPlayNotesProvider), yes, reason: '$platform');
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    }
  });
}
