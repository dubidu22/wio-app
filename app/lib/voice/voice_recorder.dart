import 'package:flutter/services.dart';

/// Whether the app may use the microphone (D-293).
enum VoicePermission { granted, refused }

/// What the on-device guard said about a transcript for this recording
/// (D-46, D-287).
enum TranscriptStatus {
  /// German on the device: partial text follows.
  ready,

  /// Older than Android 13: record only (D-61).
  androidTooOld,

  /// No on-device recognizer, or it did not answer in time: record only.
  noOnDevice,

  /// German can be loaded with the phone's own download (D-287).
  germanMissing,

  /// iOS: speech recognition may not be used; record only with its own
  /// hint (D-340).
  speechRefused,
}

/// The microphone is in use elsewhere, or recording failed to start.
class VoiceUnavailable implements Exception {
  const VoiceUnavailable(this.cause);

  final Object cause;

  @override
  String toString() => 'VoiceUnavailable($cause)';
}

/// The microphone permission is missing.
class VoiceRefused implements Exception {
  const VoiceRefused();
}

/// A finished recording: its length and the transcript heard on the device
/// (empty when there is none).
class VoiceTake {
  const VoiceTake({required this.length, this.transcript = '', this.error});

  final Duration length;
  final String transcript;

  /// The recognizer's or writer's problem, for the debug log only.
  final String? error;
}

/// What the voice screen needs from the phone (D-284). Tests use a fake.
abstract class VoiceRecorder {
  Future<VoicePermission> permission();

  /// Shows the system prompt (or answers at once after two refusals).
  Future<VoicePermission> requestPermission();

  /// Starts recording into the M4A file at [path] at once (D-288).
  /// [onTranscript] is called once with the guard's answer; [onPartial]
  /// with the text so far while speaking (D-62). [onInterrupted] is called
  /// when the phone ended the recording itself (iOS: a call, Siri, an
  /// alarm, headphones out; D-343); the screen then saves as with Stopp.
  /// Throws [VoiceRefused] or [VoiceUnavailable].
  Future<void> start(
    String path, {
    required ValueChanged<TranscriptStatus> onTranscript,
    required ValueChanged<String> onPartial,
    VoidCallback? onInterrupted,
  });

  /// Ends recording; waits at most 5 s for the last words (D-289).
  Future<VoiceTake> stop();

  /// Ends without a result; the file is deleted.
  Future<void> cancel();

  /// Starts the phone's own download of German for its recognizer.
  Future<void> downloadGerman();
}

/// The app's own Android and iOS code on channel `wio/voice` (D-284,
/// D-337).
class ChannelVoiceRecorder implements VoiceRecorder {
  ChannelVoiceRecorder([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('wio/voice') {
    _channel.setMethodCallHandler(_onCall);
  }

  final MethodChannel _channel;
  ValueChanged<TranscriptStatus>? _onTranscript;
  ValueChanged<String>? _onPartial;
  VoidCallback? _onInterrupted;

  Future<Object?> _onCall(MethodCall call) async {
    switch (call.method) {
      case 'onPartial':
        _onPartial?.call(call.arguments as String? ?? '');
      case 'onTranscription':
        final status = TranscriptStatus.values.firstWhere(
          (s) => s.name == call.arguments,
          orElse: () => TranscriptStatus.noOnDevice,
        );
        _onTranscript?.call(status);
      case 'onInterrupted':
        _onInterrupted?.call();
    }
    return null;
  }

  static VoicePermission _permission(Object? answer) =>
      answer == 'granted' ? VoicePermission.granted : VoicePermission.refused;

  @override
  Future<VoicePermission> permission() async =>
      _permission(await _channel.invokeMethod<String>('permission'));

  @override
  Future<VoicePermission> requestPermission() async =>
      _permission(await _channel.invokeMethod<String>('requestPermission'));

  @override
  Future<void> start(
    String path, {
    required ValueChanged<TranscriptStatus> onTranscript,
    required ValueChanged<String> onPartial,
    VoidCallback? onInterrupted,
  }) async {
    _onTranscript = onTranscript;
    _onPartial = onPartial;
    _onInterrupted = onInterrupted;
    try {
      await _channel.invokeMethod<void>('start', <String, Object>{
        'path': path,
      });
    } on PlatformException catch (error) {
      _onTranscript = null;
      _onPartial = null;
      _onInterrupted = null;
      if (error.code == 'refused') throw const VoiceRefused();
      throw VoiceUnavailable(error);
    }
  }

  @override
  Future<VoiceTake> stop() async {
    try {
      final answer = await _channel.invokeMapMethod<String, Object?>('stop');
      return VoiceTake(
        length: Duration(milliseconds: (answer?['millis'] as int?) ?? 0),
        transcript: (answer?['transcript'] as String?) ?? '',
        error: answer?['error'] as String?,
      );
    } on PlatformException catch (error) {
      throw VoiceUnavailable(error);
    } finally {
      _onTranscript = null;
      _onPartial = null;
      _onInterrupted = null;
    }
  }

  @override
  Future<void> cancel() async {
    _onTranscript = null;
    _onPartial = null;
    _onInterrupted = null;
    await _channel.invokeMethod<void>('cancel');
  }

  @override
  Future<void> downloadGerman() =>
      _channel.invokeMethod<void>('downloadGerman');
}
