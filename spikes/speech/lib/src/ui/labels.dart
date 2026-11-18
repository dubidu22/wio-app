import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../engine.dart';

extension ModeLabels on SpikeMode {
  String label(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (this) {
      SpikeMode.recognizeOnly => l.modeRecognizeOnly,
      SpikeMode.parallelPlugin => l.modeParallelPlugin,
      SpikeMode.oneMicNative => l.modeOneMic,
      SpikeMode.recordThenTranscribe => l.modeRecordThenTranscribe,
    };
  }

  String hint(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (this) {
      SpikeMode.recognizeOnly => l.modeRecognizeOnlyHint,
      SpikeMode.parallelPlugin => l.modeParallelPluginHint,
      SpikeMode.oneMicNative => l.modeOneMicHint,
      SpikeMode.recordThenTranscribe => l.modeRecordThenTranscribeHint,
    };
  }
}
