import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../results.dart';

String _pct(double v) => (v * 100).toStringAsFixed(1);

/// The measured numbers of one run, in words.
class ResultView extends StatelessWidget {
  const ResultView({super.key, required this.result});
  final RunResult result;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = result;
    final rec = r.recording;
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    return DefaultTextStyle.merge(
      style: textStyle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.transcript, style: Theme.of(context).textTheme.titleMedium),
          Text(r.transcript.isEmpty ? l.noTranscript : r.transcript),
          const SizedBox(height: 8),
          if (r.werNormalized != null && r.werRaw != null)
            Text(l.werLine(_pct(r.werNormalized!), _pct(r.werRaw!))),
          if (r.msToText >= 0) Text(l.timeToText(r.msToText)),
          if (rec == null)
            Text(l.noRecording)
          else ...[
            Text(l.recordingLine(rec.seconds.toStringAsFixed(1), rec.peakDbfs.toStringAsFixed(1))),
            if (rec.silent) Text(l.recordingSilent, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
          if (r.recognizerEndedEarly) Text(l.endedEarly),
          if (r.error != null)
            Text(l.errorLine(r.error!), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
