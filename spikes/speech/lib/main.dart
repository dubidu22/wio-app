import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'src/app.dart';
import 'src/engine.dart';
import 'src/platform/native_speech.dart';
import 'src/platform/plugin_recognizer.dart';
import 'src/platform/plugin_recorder.dart';
import 'src/results.dart';
import 'src/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final results = ResultsLog(file: File('${dir.path}/results.json'));
  await results.load();
  final recorder = PluginRecorder();
  final native = NativeSpeech(recorder);
  var counter = 0;
  runApp(SpikeApp(
    services: SpikeServices(
      platform: native,
      engines: SpikeEngines(
        recognizer: PluginRecognizer(),
        recorder: recorder,
        oneMic: native,
        fileTranscriber: native,
      ),
      clock: SystemClock(),
      results: results,
      // Recordings stay in the app's private folder and go with the app.
      recordingPath: (mode, item) => '${dir.path}/'
          '${mode.name}-${item.id}-${DateTime.now().millisecondsSinceEpoch}-${counter++}.m4a',
      copyToClipboard: (text) => Clipboard.setData(ClipboardData(text: text)),
    ),
  ));
}
