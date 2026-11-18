import 'engine.dart';
import 'results.dart';
import 'sentences.dart';

/// Everything the screens need, injected so tests can use fakes.
class SpikeServices {
  SpikeServices({
    required this.platform,
    required this.engines,
    required this.clock,
    required this.results,
    required this.recordingPath,
    required this.copyToClipboard,
  });

  final SpeechPlatform platform;
  final SpikeEngines engines;
  final SpikeClock clock;
  final ResultsLog results;
  final String Function(SpikeMode mode, TestItem item) recordingPath;
  final Future<void> Function(String text) copyToClipboard;
}

const sourceCodeUrl = 'https://github.com/dubidu22/wio-app';
