import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:wio_app/voice/voice_recorder.dart';

import 'm4a.dart';

/// A recorder for widget tests (plan 060): writes [sampleM4a] to the path
/// at [stop] when [writeFile] is set, and lets the test send the guard's
/// answer and partial text.
class FakeVoiceRecorder implements VoiceRecorder {
  FakeVoiceRecorder({
    this.permissionNow = VoicePermission.granted,
    this.permissionAfterAsking = VoicePermission.granted,
    this.writeFile = false,
  });

  VoicePermission permissionNow;
  VoicePermission permissionAfterAsking;
  final bool writeFile;

  /// Thrown by [start], for example [VoiceUnavailable].
  Exception? startError;

  /// What [stop] answers.
  VoiceTake take = const VoiceTake(
    length: Duration(seconds: 7),
    transcript: 'Kiste mit Wintersachen im Keller',
  );

  int asked = 0;
  int started = 0;
  int stopped = 0;
  int cancelled = 0;
  int downloads = 0;
  String? path;
  ValueChanged<TranscriptStatus>? _onTranscript;
  ValueChanged<String>? _onPartial;
  VoidCallback? _onInterrupted;

  bool get recording => started > stopped + cancelled;

  @override
  Future<VoicePermission> permission() async => permissionNow;

  @override
  Future<VoicePermission> requestPermission() async {
    asked++;
    permissionNow = permissionAfterAsking;
    return permissionNow;
  }

  @override
  Future<void> start(
    String path, {
    required ValueChanged<TranscriptStatus> onTranscript,
    required ValueChanged<String> onPartial,
    VoidCallback? onInterrupted,
  }) async {
    final error = startError;
    if (error != null) throw error;
    started++;
    this.path = path;
    _onTranscript = onTranscript;
    _onPartial = onPartial;
    _onInterrupted = onInterrupted;
  }

  /// The phone ended the recording itself (iOS, D-343).
  void interrupt() => _onInterrupted?.call();

  /// The guard's answer, as the phone sends it.
  void transcript(TranscriptStatus status) => _onTranscript?.call(status);

  /// Text so far, as the phone sends it.
  void partial(String text) => _onPartial?.call(text);

  @override
  Future<VoiceTake> stop() async {
    stopped++;
    final target = path;
    if (writeFile && target != null) {
      File(target).writeAsBytesSync(sampleM4a(), flush: true);
    }
    return take;
  }

  @override
  Future<void> cancel() async {
    cancelled++;
  }

  @override
  Future<void> downloadGerman() async {
    downloads++;
  }
}
