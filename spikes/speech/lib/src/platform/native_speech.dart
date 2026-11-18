import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../engine.dart';
import 'plugin_recorder.dart';

/// Own Android code in `MainActivity.kt` / `SpeechChannel.kt`: the on-device
/// guard, the one-microphone session and file transcription (Android 13+).
class NativeSpeech implements SpeechPlatform, OneMicSession, FileTranscriber {
  NativeSpeech(this._recorder) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onPartial') _onPartial?.call(call.arguments as String);
    });
  }

  static const _channel = MethodChannel('wio.spike/speech');
  final PluginRecorder _recorder;
  void Function(String)? _onPartial;

  bool get _android => Platform.isAndroid;

  Future<T> _call<T>(String method, [Object? args]) async {
    try {
      return (await _channel.invokeMethod<T>(method, args)) as T;
    } on PlatformException catch (e) {
      throw SpikeEngineException('${e.code}: ${e.message ?? ''}');
    }
  }

  @override
  Future<DeviceInfo> deviceInfo() async {
    if (!_android) {
      return DeviceInfo(
          platform: Platform.operatingSystem,
          model: '?',
          manufacturer: '?',
          sdkInt: 0);
    }
    final m = (await _call<Map<Object?, Object?>>('deviceInfo')).cast<String, Object?>();
    return DeviceInfo(
      platform: 'android',
      model: m['model']! as String,
      manufacturer: m['manufacturer']! as String,
      sdkInt: m['sdkInt']! as int,
    );
  }

  @override
  Future<bool> ensureMicPermission() => _recorder.hasPermission();

  @override
  Future<GuardResult> checkOnDevice(SpikeMode mode) async {
    if (!_android) {
      // iOS: the plugin sets requiresOnDeviceRecognition, so it fails rather
      // than uploading. Modes 2 and 3 are Android-only until O-10 says iPhone.
      return mode.needsAudioSource
          ? const GuardResult(GuardStatus.notOnThisPlatform)
          : const GuardResult(GuardStatus.ready);
    }
    final m = (await _call<Map<Object?, Object?>>(
            'checkOnDevice', {'needsAudioSource': mode.needsAudioSource}))
        .cast<String, Object?>();
    return GuardResult(GuardStatus.values.byName(m['status']! as String),
        detail: (m['detail'] as String?) ?? '');
  }

  @override
  Future<void> requestGermanDownload() => _call<void>('downloadGerman');

  @override
  Future<void> start(String path, void Function(String partial) onPartial) async {
    _onPartial = onPartial;
    await _call<void>('oneMicStart', {'path': path});
  }

  @override
  Future<OneMicResult> stop() async {
    try {
      final m = (await _call<Map<Object?, Object?>>('oneMicStop')).cast<String, Object?>();
      final error = m['error'] as String?;
      final transcript = m['transcript']! as String;
      if (error != null && transcript.isEmpty) throw SpikeEngineException(error);
      return OneMicResult(
          transcript: transcript, peakDbfs: (m['peakDbfs']! as num).toDouble());
    } finally {
      _onPartial = null;
    }
  }

  @override
  Future<String> transcribe(String path) async {
    final m = (await _call<Map<Object?, Object?>>('transcribeFile', {'path': path}))
        .cast<String, Object?>();
    final error = m['error'] as String?;
    final transcript = m['transcript']! as String;
    if (error != null && transcript.isEmpty) throw SpikeEngineException(error);
    return transcript;
  }
}
