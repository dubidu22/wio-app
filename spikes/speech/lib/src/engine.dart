/// Interfaces between the spike's logic and the speech/recording engines.
/// Real implementations live in `platform/`; tests use fakes.
library;

enum SpikeMode {
  /// Plugin recognizer on the device, no recording. Baseline for quality.
  recognizeOnly,

  /// Plugin recognizer and plugin recorder at the same time.
  parallelPlugin,

  /// Own Kotlin code: one microphone feeds recognizer and M4A file.
  oneMicNative,

  /// Record first, then transcribe the file on the device (D-22).
  recordThenTranscribe;

  /// Modes 2 and 3 feed audio into the recognizer (Android 13+).
  bool get needsAudioSource =>
      this == SpikeMode.oneMicNative || this == SpikeMode.recordThenTranscribe;

  bool get records => this != SpikeMode.recognizeOnly;
}

class SpikeEngineException implements Exception {
  SpikeEngineException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Monotonic time, injectable for tests.
abstract interface class SpikeClock {
  Duration now();
}

class SystemClock implements SpikeClock {
  final Stopwatch _watch = Stopwatch()..start();
  @override
  Duration now() => _watch.elapsed;
}

abstract interface class LiveRecognizer {
  Future<void> start(void Function(String partial) onPartial);

  /// Stops listening and returns the final transcript.
  Future<String> stop();

  /// True when the recognizer ended by itself (silence) before stop().
  bool get endedOnItsOwn;
}

abstract interface class Recorder {
  Future<void> start(String path);

  /// Stops and returns the loudest level seen, in dBFS (-160 = silence).
  Future<double> stop();
}

class OneMicResult {
  const OneMicResult({required this.transcript, required this.peakDbfs});
  final String transcript;
  final double peakDbfs;
}

abstract interface class OneMicSession {
  Future<void> start(String path, void Function(String partial) onPartial);
  Future<OneMicResult> stop();
}

abstract interface class FileTranscriber {
  Future<String> transcribe(String path);
}

class SpikeEngines {
  const SpikeEngines({
    required this.recognizer,
    required this.recorder,
    required this.oneMic,
    required this.fileTranscriber,
  });
  final LiveRecognizer recognizer;
  final Recorder recorder;
  final OneMicSession oneMic;
  final FileTranscriber fileTranscriber;
}

enum GuardStatus {
  /// On-device recognition for German is available.
  ready,

  /// The phone cannot recognize without internet; the spike refuses.
  noOnDevice,

  /// On-device recognition exists but German is not installed.
  germanMissing,

  /// The mode needs Android 13 or newer.
  androidTooOld,

  /// The mode is not built for this platform (iOS modes 2 and 3).
  notOnThisPlatform,
}

class DeviceInfo {
  const DeviceInfo({
    required this.platform,
    required this.model,
    required this.manufacturer,
    required this.sdkInt,
  });
  final String platform;
  final String model;
  final String manufacturer;
  final int sdkInt;

  String get summary => '$manufacturer $model, $platform sdk $sdkInt';
}

class GuardResult {
  const GuardResult(this.status, {this.detail = ''});
  final GuardStatus status;

  /// Diagnostic text for the results (languages found, error codes).
  final String detail;
}

/// Platform checks that come before every run (D-46).
abstract interface class SpeechPlatform {
  Future<DeviceInfo> deviceInfo();
  Future<bool> ensureMicPermission();
  Future<GuardResult> checkOnDevice(SpikeMode mode);
  Future<void> requestGermanDownload();
}
