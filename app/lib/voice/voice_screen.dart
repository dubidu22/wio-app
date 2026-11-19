import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/queries.dart';
import '../l10n/app_localizations.dart';
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'voice_notes.dart';
import 'voice_providers.dart';
import 'voice_recorder.dart';

/// Size of the round main button "Stopp" (UX rules 3 and 10, as the
/// camera's shutter).
const double stopButtonSize = 96;

/// The voice note (KB workflows.md "Voice note", D-284..D-297): opens
/// straight into recording (D-288); **Stopp** keeps the note with its
/// recording and the German text heard on the device (D-290). **Fertig**,
/// back and leaving the app also save (D-291); after 10 minutes it saves by
/// itself (D-292). Part of the room, picture or customer task (as D-271).
class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({
    required this.customerId,
    this.roomId,
    this.pictureId,
    super.key,
  });

  final String customerId;
  final String? roomId;
  final String? pictureId;

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

enum _VoiceState { opening, recording, refused, unavailable, saving, kept }

class _VoiceScreenState extends ConsumerState<VoiceScreen>
    with WidgetsBindingObserver {
  late final VoiceRecorder _recorder = ref.read(voiceRecorderProvider);
  late final VoiceNotes _notes = ref.read(voiceNotesProvider);
  late final VoiceTarget _target = (
    customerId: widget.customerId,
    roomId: widget.roomId,
    pictureId: widget.pictureId,
  );

  _VoiceState _state = _VoiceState.opening;
  TranscriptStatus? _transcript;
  String _partial = '';
  bool _loadingGerman = false;
  String? _path;
  Timer? _ticker;
  int _seconds = 0;
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_open());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _attempt++;
    _ticker?.cancel();
    if (_state == _VoiceState.recording) {
      // Leaving in any other way also keeps the note (D-291).
      unawaited(_keep(_path!, notify: null));
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only going to the background ends a running recording, and keeps it
    // (D-291). Android reports "inactive" on any focus loss (notification
    // shade, a call's heads-up, a system dialog, the permission prompt);
    // recording goes on then (PR 73 review S1).
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        if (_state == _VoiceState.recording) unawaited(_stop());
      case AppLifecycleState.inactive:
      case AppLifecycleState.resumed:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _open() async {
    final attempt = ++_attempt;
    setState(() {
      _state = _VoiceState.opening;
      _transcript = null;
      _partial = '';
      _seconds = 0;
    });
    String? path;
    _VoiceState next;
    try {
      var permission = await _recorder.permission();
      if (permission != VoicePermission.granted) {
        permission = await _recorder.requestPermission();
      }
      if (permission != VoicePermission.granted) throw const VoiceRefused();
      if (!mounted || attempt != _attempt) return;
      path = await _notes.newPath();
      await _recorder.start(
        path,
        onTranscript: (status) {
          if (mounted && attempt == _attempt) {
            setState(() => _transcript = status);
          }
        },
        onPartial: (text) {
          if (mounted && attempt == _attempt) setState(() => _partial = text);
        },
      );
      next = _VoiceState.recording;
    } on VoiceRefused {
      next = _VoiceState.refused;
    } on Object catch (error) {
      debugPrint('wio voice: recording did not start: $error');
      next = _VoiceState.unavailable;
    }
    if (next != _VoiceState.recording && path != null) {
      await _notes.discard(path);
    }
    if (!mounted || attempt != _attempt) {
      if (next == _VoiceState.recording) await _recorder.cancel();
      return;
    }
    _path = path;
    if (next == _VoiceState.recording) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _seconds++);
        if (Duration(seconds: _seconds) >= voiceNoteLimit) unawaited(_stop());
      });
    }
    setState(() => _state = next);
  }

  /// Stopp, Fertig, back, leaving the app and the time limit all end here.
  Future<void> _stop() async {
    if (_state != _VoiceState.recording) {
      if (_state != _VoiceState.saving && _state != _VoiceState.kept) _leave();
      return;
    }
    _ticker?.cancel();
    setState(() => _state = _VoiceState.saving);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    await _keep(
      _path!,
      notify: (text) => messenger.showSnackBar(SnackBar(content: Text(text))),
      l10n: l10n,
    );
    if (!mounted) return;
    // The note is kept: back may leave now, after this frame.
    setState(() => _state = _VoiceState.kept);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _leave();
    });
  }

  Future<void> _keep(
    String path, {
    required void Function(String text)? notify,
    AppLocalizations? l10n,
  }) async {
    String? message;
    try {
      final take = await _recorder.stop();
      if (take.error != null) debugPrint('wio voice: ${take.error}');
      final id = await _notes.keep(
        target: _target,
        path: path,
        length: take.length,
        transcript: take.transcript,
      );
      if (l10n != null) {
        final text = take.transcript.trim();
        message = id == null
            ? l10n.voiceTooShort
            : text.isEmpty
            ? l10n.voiceSavedNoText
            : l10n.voiceSaved(_start(text));
      }
    } on Object catch (error) {
      debugPrint('wio voice: note not kept: $error');
      await _notes.discard(path);
      message = l10n?.voiceNotSaved;
    }
    if (message != null) notify?.call(message);
  }

  /// The first words of [text] for the note under the screen.
  static String _start(String text) {
    const max = 60;
    if (text.length <= max) return text;
    final cut = text.lastIndexOf(' ', max);
    return '${text.substring(0, cut > 20 ? cut : max)} …';
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    final c = '/customers/${widget.customerId}';
    final room = widget.roomId;
    final base = room == null ? c : '$c/rooms/$room';
    final picture = widget.pictureId;
    context.go(picture == null ? base : '$base/pictures/$picture');
  }

  Future<void> _loadGerman() async {
    setState(() => _loadingGerman = true);
    try {
      await _recorder.downloadGerman();
    } on Object catch (error) {
      debugPrint('wio voice: German download not started: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      // While recording or saving, back saves first (D-291).
      canPop: switch (_state) {
        _VoiceState.recording || _VoiceState.saving => false,
        _ => true,
      },
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_stop());
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: WioBackButton(label: l10n.voiceDone, onPressed: _stop),
          leadingWidth: wioBackButtonWidth(context),
          title: Text(_title(l10n)),
        ),
        body: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: _body(context, l10n),
          ),
        ),
        bottomNavigationBar: _state == _VoiceState.recording
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Center(
                    heightFactor: 1,
                    child: Semantics(
                      button: true,
                      label: l10n.voiceStopLabel,
                      excludeSemantics: true,
                      child: SizedBox.square(
                        dimension: stopButtonSize,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size.square(stopButtonSize),
                          ),
                          onPressed: _stop,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(l10n.voiceStop),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  List<Widget> _body(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    Widget button(String label, VoidCallback onPressed) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(64)),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
    switch (_state) {
      case _VoiceState.opening:
        return <Widget>[HintText(l10n.voiceOpening)];
      case _VoiceState.saving:
      case _VoiceState.kept:
        return <Widget>[
          Text(l10n.voiceSaving, style: theme.textTheme.titleMedium),
        ];
      case _VoiceState.refused:
        return <Widget>[
          HintText(l10n.voiceDenied),
          HintText(l10n.voiceDeniedHelp),
          button(l10n.voiceAskAgain, _open),
        ];
      case _VoiceState.unavailable:
        return <Widget>[
          HintText(l10n.voiceUnavailable),
          button(l10n.voiceTryAgain, _open),
        ];
      case _VoiceState.recording:
        final status = _transcript;
        return <Widget>[
          Text(
            l10n.voiceRecording(_clock(_seconds)),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          if (status == TranscriptStatus.ready && _partial.isEmpty)
            HintText(l10n.voiceListening),
          if (_partial.isNotEmpty)
            Text(_partial, style: theme.textTheme.headlineSmall),
          if (status != null && status != TranscriptStatus.ready)
            HintText(l10n.voiceNoTranscript),
          if (status == TranscriptStatus.germanMissing) ...<Widget>[
            HintText(l10n.voiceGermanMissing),
            if (_loadingGerman)
              HintText(l10n.voiceGermanLoading)
            else
              button(l10n.voiceLoadGerman, _loadGerman),
          ],
        ];
    }
  }

  static String _clock(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  String _title(AppLocalizations l10n) {
    if (widget.pictureId != null) return l10n.voicePictureTitle;
    final room = widget.roomId;
    if (room != null) {
      final view = ref.watch(
        roomProvider((customerId: widget.customerId, id: room)),
      );
      return switch (view) {
        AsyncData(value: final RoomScreenView v) => v.name ?? l10n.unnamedRoom,
        _ => '',
      };
    }
    final view = ref.watch(customerProvider(widget.customerId));
    return switch (view) {
      AsyncData(value: final CustomerView v) => v.name ?? l10n.unnamedCustomer,
      _ => '',
    };
  }
}
