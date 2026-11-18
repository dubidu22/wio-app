import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../engine.dart';
import '../results.dart';
import '../run_controller.dart';
import '../sentences.dart';
import '../services.dart';
import 'big_button.dart';
import 'labels.dart';
import 'result_view.dart';
import 'results_screen.dart';

enum _Phase { checking, blocked, idle, listening, processing, done }

/// One mode: the guard first, then the six items, two taps each
/// ("Sprechen", "Stopp").
class TestScreen extends StatefulWidget {
  const TestScreen({super.key, required this.services, required this.mode});
  final SpikeServices services;
  final SpikeMode mode;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  _Phase _phase = _Phase.checking;
  GuardStatus? _guard;
  bool _micDenied = false;
  int _index = 0;
  String _partial = '';
  String? _startError;
  RunController? _controller;
  RunResult? _result;

  TestItem get _item => testItems[_index];

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() => _phase = _Phase.checking);
    final platform = widget.services.platform;
    final mic = await platform.ensureMicPermission();
    final guard = mic ? await platform.checkOnDevice(widget.mode) : null;
    if (!mounted) return;
    setState(() {
      _micDenied = !mic;
      _guard = guard?.status;
      _phase = mic && guard!.status == GuardStatus.ready ? _Phase.idle : _Phase.blocked;
    });
  }

  Future<void> _start() async {
    final controller = RunController(
      mode: widget.mode,
      item: _item,
      engines: widget.services.engines,
      clock: widget.services.clock,
      recordingPath: widget.services.recordingPath,
      onPartial: (text) {
        if (mounted) setState(() => _partial = text);
      },
    );
    setState(() {
      _partial = '';
      _startError = null;
      _result = null;
      _phase = _Phase.listening;
    });
    try {
      await controller.start();
      _controller = controller;
    } on StartFailed catch (e) {
      if (mounted) {
        setState(() {
          _startError = e.message;
          _phase = _Phase.idle;
        });
      }
    }
  }

  Future<void> _stop() async {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _phase = _Phase.processing);
    final result = await controller.stop();
    await widget.services.results.add(result);
    if (!mounted) return;
    setState(() {
      _controller = null;
      _result = result;
      _phase = _Phase.done;
    });
  }

  void _next() {
    if (_index + 1 >= testItems.length) {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
          builder: (_) => ResultsScreen(services: widget.services)));
      return;
    }
    setState(() {
      _index++;
      _result = null;
      _partial = '';
      _phase = _Phase.idle;
    });
  }

  String _blockedText(AppLocalizations l) {
    if (_micDenied) return l.micDenied;
    return switch (_guard) {
      GuardStatus.germanMissing => l.guardGermanMissing,
      GuardStatus.androidTooOld => l.guardAndroidTooOld,
      GuardStatus.notOnThisPlatform => l.guardNotOnThisPlatform,
      _ => l.guardNoOnDevice,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final big = Theme.of(context).textTheme.headlineSmall;
    final body = switch (_phase) {
      _Phase.checking => [Text(l.guardChecking, style: big)],
      _Phase.blocked => [
          Text(_blockedText(l), style: big),
          if (_guard == GuardStatus.germanMissing) ...[
            const SizedBox(height: 16),
            Text(l.loadGermanHint),
            const SizedBox(height: 8),
            BigButton(
              key: const ValueKey('load-german'),
              label: l.loadGerman,
              primary: false,
              onPressed: () => widget.services.platform.requestGermanDownload(),
            ),
          ],
        ],
      _ => [
          Text(
            _item.isFreeNote
                ? l.freeNoteTitle
                : l.itemCounter(_index + 1, testItems.length),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_item.isFreeNote)
            Text(l.freeNoteInstructions, style: big)
          else ...[
            Text(l.readAloud),
            const SizedBox(height: 4),
            Text(_item.reference!, style: big),
          ],
          const SizedBox(height: 24),
          if (_phase == _Phase.listening) ...[
            Text(l.listening, style: Theme.of(context).textTheme.titleMedium),
            Text(_partial),
          ],
          if (_phase == _Phase.processing)
            Text(l.waitingForText, style: Theme.of(context).textTheme.titleMedium),
          if (_startError != null) Text(l.errorLine(_startError!)),
          if (_result != null) ResultView(result: _result!),
        ],
    };

    return Scaffold(
      appBar: spikeAppBar(context, widget.mode.label(context), backLabel: l.back),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(padding: const EdgeInsets.all(16), children: body),
            ),
            Padding(padding: const EdgeInsets.all(16), child: _mainButtons(l)),
          ],
        ),
      ),
    );
  }

  Widget _mainButtons(AppLocalizations l) => switch (_phase) {
        _Phase.checking => const SizedBox.shrink(),
        _Phase.blocked => BigButton(
            key: const ValueKey('check-again'), label: l.checkAgain, onPressed: _check),
        _Phase.idle =>
          BigButton(key: const ValueKey('speak'), label: l.speak, onPressed: _start),
        _Phase.listening => BigButton(
            key: const ValueKey('stop'),
            label: l.stop,
            onPressed: _controller == null ? null : _stop),
        _Phase.processing =>
          BigButton(key: const ValueKey('stop'), label: l.stop, onPressed: null),
        _Phase.done => Row(
            children: [
              Expanded(
                child: BigButton(
                    key: const ValueKey('again'),
                    label: l.again,
                    primary: false,
                    onPressed: _start),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BigButton(key: const ValueKey('next'), label: l.next, onPressed: _next),
              ),
            ],
          ),
      };
}
