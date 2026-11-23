import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../camera/camera_problem.dart';
import '../camera/capture_camera.dart';
import '../l10n/app_localizations.dart';
import '../planning/place_screen.dart' show entryLocation;
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'new_entry.dart';
import 'qr_scanner.dart';
import 'scan_providers.dart';

/// Where the scan screen of [from] is (D-468).
String scanLocation(NewEntryFrom from) => from.roomId == null
    ? '/customers/${from.customerId}/eintrag'
    : '/customers/${from.customerId}/rooms/${from.roomId}/eintrag';

/// Where the photo camera of a new entry is (D-468).
String entryCameraLocation(String customerId, String entryId) =>
    '${entryLocation(customerId, entryId)}/kamera';

/// "+ Eintrag" (D-465, D-466): opens straight into the live image (UX rule
/// 5). The first readable QR code that fits (D-469) opens the live entry
/// that has it (D-428) or creates an entry with it; **Ohne Code**, the main
/// button, creates one without a code. A new entry goes on to its photo
/// camera; from a room it is placed on that room's floor (D-424, D-425).
/// Part of the customer or room task, not a level of its own (D-468).
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({required this.customerId, this.roomId, super.key});

  final String customerId;
  final String? roomId;

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

enum _ScanState { opening, ready, denied, unavailable }

class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver {
  QrScanner? _scanner;
  // Cancelled in _release.
  // ignore: cancel_subscriptions
  StreamSubscription<String>? _codes;
  _ScanState _state = _ScanState.opening;
  int _opening = 0;
  bool _released = false;

  /// An entry is being found or created: nothing else is taken (D-466).
  bool _busy = false;

  /// The last code read was longer than a code may be (D-469).
  bool _tooLong = false;

  NewEntryFrom get _from =>
      (customerId: widget.customerId, roomId: widget.roomId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_open());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _opening++;
    unawaited(_release());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // As the photo camera (PR 69 B1): a ready camera is let go in the
    // background and taken again on return; while it opens, or after it
    // was refused or failed, the hint's button retries.
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        if (_scanner == null) return;
        _released = true;
        setState(() => _state = _ScanState.opening);
        unawaited(_release());
      case AppLifecycleState.resumed:
        if (_released && !_busy) {
          _released = false;
          unawaited(_open());
        }
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _release() async {
    final scanner = _scanner;
    _scanner = null;
    final codes = _codes;
    _codes = null;
    unawaited(codes?.cancel());
    await scanner?.close();
  }

  Future<void> _open() async {
    final attempt = ++_opening;
    final scanner = ref.read(qrScannerProvider)();
    setState(() => _state = _ScanState.opening);
    _ScanState next;
    try {
      await scanner.open();
      next = _ScanState.ready;
    } on CameraDenied {
      next = _ScanState.denied;
    } on Object {
      next = _ScanState.unavailable;
    }
    if (!mounted || attempt != _opening || _busy) {
      await scanner.close();
      return;
    }
    if (next == _ScanState.ready) {
      _scanner = scanner;
      _codes = scanner.codes.listen(_onCode);
    } else {
      await scanner.close();
    }
    setState(() => _state = next);
  }

  void _onCode(String code) {
    if (_busy || !mounted) return;
    if (!codeFits(code)) {
      if (!_tooLong) setState(() => _tooLong = true);
      return;
    }
    unawaited(_take(code));
  }

  /// Finds or creates the entry for [code] (null: **Ohne Code**) and opens
  /// it, or its photo camera when it is new.
  Future<void> _take(String? code) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final EntryFound found;
    try {
      found = await findOrCreateEntry(
        ref.read(databaseProvider),
        ref.read(entryWriterProvider),
        _from,
        code: code,
      );
    } on Object catch (error) {
      // A customer or room gone meanwhile has its own words; anything
      // else (a database error) is a plain "try again" (PR 113 S1).
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error is ArgumentError ? l10n.scanFailed : l10n.scanRetry,
          ),
        ),
      );
      if (mounted) setState(() => _busy = false);
      return;
    }
    if (!mounted) return;
    // The scanner lets the camera go before the photo camera takes it
    // (PR 113 M1).
    _opening++;
    await _release();
    if (!mounted) return;
    context.go(
      found.created
          ? entryCameraLocation(found.customerId, found.entryId)
          : entryLocation(found.customerId, found.entryId),
    );
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      final room = widget.roomId;
      context.go(
        room == null
            ? '/customers/${widget.customerId}'
            : '/customers/${widget.customerId}/rooms/$room',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scanner = _scanner;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: WioBackButton(onPressed: _back),
        leadingWidth: wioBackButtonWidth(context),
        title: Text(l10n.scanTitle),
      ),
      body: switch (_state) {
        _ScanState.ready when scanner != null => ColoredBox(
          color: Colors.black,
          child: Center(child: scanner.preview()),
        ),
        _ScanState.denied => CameraProblem(
          lines: <String>[l10n.cameraDenied, l10n.cameraDeniedHelp],
          button: l10n.cameraAskAgain,
          onPressed: _open,
        ),
        _ScanState.unavailable => CameraProblem(
          lines: <String>[l10n.cameraUnavailable],
          button: l10n.cameraTryAgain,
          onPressed: _open,
        ),
        _ => const ColoredBox(color: Colors.black),
      },
      bottomNavigationBar: SafeArea(
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: wioMaxContentWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final line in <String>[
                    if (_state == _ScanState.ready) l10n.scanHold,
                    if (_tooLong) l10n.scanCodeTooLong,
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        line,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(64),
                    ),
                    onPressed: _busy ? null : () => _take(null),
                    child: Text(l10n.scanWithoutCode),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
