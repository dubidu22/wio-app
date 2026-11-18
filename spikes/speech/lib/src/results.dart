import 'dart:convert';
import 'dart:io';

import 'engine.dart';

/// Peak below this level counts as "the recording is silent".
const silentBelowDbfs = -50.0;

class RecordingInfo {
  const RecordingInfo({required this.seconds, required this.peakDbfs, required this.bytes});
  final double seconds;
  final double peakDbfs;
  final int bytes;

  bool get silent => peakDbfs < silentBelowDbfs;

  Map<String, Object?> toJson() =>
      {'seconds': seconds, 'peakDbfs': peakDbfs, 'bytes': bytes};

  static RecordingInfo fromJson(Map<String, Object?> j) => RecordingInfo(
        seconds: (j['seconds']! as num).toDouble(),
        peakDbfs: (j['peakDbfs']! as num).toDouble(),
        bytes: j['bytes']! as int,
      );
}

class RunResult {
  const RunResult({
    required this.mode,
    required this.itemId,
    required this.transcript,
    required this.werRaw,
    required this.werNormalized,
    required this.msToText,
    required this.recording,
    required this.recognizerEndedEarly,
    this.error,
  });

  final SpikeMode mode;
  final String itemId;
  final String transcript;
  final double? werRaw;
  final double? werNormalized;
  final int msToText;
  final RecordingInfo? recording;
  final bool recognizerEndedEarly;
  final String? error;

  Map<String, Object?> toJson() => {
        'mode': mode.name,
        'itemId': itemId,
        'transcript': transcript,
        'werRaw': werRaw,
        'werNormalized': werNormalized,
        'msToText': msToText,
        'recording': recording?.toJson(),
        'recognizerEndedEarly': recognizerEndedEarly,
        'error': error,
      };

  static RunResult fromJson(Map<String, Object?> j) => RunResult(
        mode: SpikeMode.values.byName(j['mode']! as String),
        itemId: j['itemId']! as String,
        transcript: j['transcript']! as String,
        werRaw: (j['werRaw'] as num?)?.toDouble(),
        werNormalized: (j['werNormalized'] as num?)?.toDouble(),
        msToText: j['msToText']! as int,
        recording: j['recording'] == null
            ? null
            : RecordingInfo.fromJson((j['recording']! as Map).cast<String, Object?>()),
        recognizerEndedEarly: j['recognizerEndedEarly']! as bool,
        error: j['error'] as String?,
      );
}

String _pct(double? v) => v == null ? '-' : (v * 100).toStringAsFixed(1);
String _cell(String s) => s.replaceAll('|', '/').replaceAll('\n', ' ');

/// Plain-text table for the clipboard. Column names are English because the
/// table is data for the developers, not UI text.
String resultsAsMarkdown(DeviceInfo device, List<RunResult> results) {
  final b = StringBuffer()
    ..writeln('speech spike results; device: ${device.summary}')
    ..writeln()
    ..writeln('| mode | item | WER raw | WER norm | ms to text | rec s | peak dBFS | rec bytes | ended early | error | transcript |')
    ..writeln('|---|---|---|---|---|---|---|---|---|---|---|');
  for (final r in results) {
    final rec = r.recording;
    b.writeln('| ${r.mode.name} | ${r.itemId} | ${_pct(r.werRaw)} | ${_pct(r.werNormalized)} | '
        '${r.msToText} | ${rec == null ? '-' : rec.seconds.toStringAsFixed(1)} | '
        '${rec == null ? '-' : rec.peakDbfs.toStringAsFixed(1)} | ${rec == null ? '-' : rec.bytes} | '
        '${r.recognizerEndedEarly ? 'yes' : 'no'} | ${_cell(r.error ?? '')} | ${_cell(r.transcript)} |');
  }
  return b.toString();
}

/// Keeps results in memory and, if a file is given, on disk so that they
/// survive the app being closed.
class ResultsLog {
  ResultsLog({this.file});
  final File? file;
  final List<RunResult> _results = [];

  List<RunResult> get results => List.unmodifiable(_results);

  Future<void> load() async {
    final f = file;
    if (f == null || !f.existsSync()) return;
    final list = jsonDecode(await f.readAsString()) as List<Object?>;
    _results
      ..clear()
      ..addAll(list.map((e) => RunResult.fromJson((e! as Map).cast<String, Object?>())));
  }

  Future<void> add(RunResult r) async {
    _results.add(r);
    final f = file;
    if (f != null) {
      await f.writeAsString(jsonEncode(_results.map((e) => e.toJson()).toList()));
    }
  }
}
