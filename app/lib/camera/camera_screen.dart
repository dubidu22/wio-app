import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/queries.dart';
import '../l10n/app_localizations.dart';
import '../media/local_picture.dart';
import '../media/media_store.dart';
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'camera_providers.dart';
import 'capture_camera.dart';
import 'capture_queue.dart';

/// Size of the shutter button "Foto" (UX rules 3 and 10).
const double shutterSize = 96;

/// How strongly the before picture shows over the live image of the after
/// camera: fixed, no slider (UX rule 6, D-277).
const double afterOverlayOpacity = 0.4;

/// The camera (UX rule 5, D-265..D-271): opens straight into the live
/// image; every press of "Foto" is one picture, stored in the background
/// (D-268), with no step to confirm it. "Fertig" top left returns (D-270).
/// Part of the room or customer task, not a level of its own (D-271).
///
/// With [afterOf] it is the after camera (D-276): the before picture shows
/// faintly over the live image (D-277), every press is an after picture of
/// it, and "Fertig" returns to that picture.
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({
    required this.customerId,
    this.roomId,
    this.afterOf,
    super.key,
  });

  final String customerId;
  final String? roomId;

  /// The picture whose after pictures are taken, or null.
  final String? afterOf;

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

enum _CameraState { opening, ready, denied, unavailable }

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  late final CaptureSession _session = CaptureSession((
    customerId: widget.customerId,
    roomId: widget.roomId,
    afterOf: widget.afterOf,
  ));
  CaptureCamera? _camera;
  _CameraState _state = _CameraState.opening;
  bool _taking = false;
  bool _released = false;

  /// Presses that came while a shot was being taken; each is one more
  /// picture right after it (UX rule 5, PR 69 S1).
  int _extraPresses = 0;
  bool _flash = false;
  int _opening = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session.addListener(_changed);
    unawaited(_open());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // The queue keeps the session until its shots are stored (D-268).
    _session.removeListener(_changed);
    _opening++;
    unawaited(_camera?.close());
    _camera = null;
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A ready camera must be let go while the app is in the background and
    // taken again on return. While the camera opens (the permission prompt
    // itself makes the app inactive), or after it was refused or failed,
    // the lifecycle is ignored: the hint's button retries (PR 69 B1).
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        final camera = _camera;
        if (camera == null) return;
        _camera = null;
        _released = true;
        _extraPresses = 0;
        setState(() => _state = _CameraState.opening);
        unawaited(camera.close());
      case AppLifecycleState.resumed:
        if (_released) {
          _released = false;
          unawaited(_open());
        }
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _open() async {
    final attempt = ++_opening;
    final camera = ref.read(captureCameraProvider)();
    setState(() => _state = _CameraState.opening);
    _CameraState next;
    try {
      await camera.open();
      next = _CameraState.ready;
    } on CameraDenied {
      next = _CameraState.denied;
    } on Object {
      next = _CameraState.unavailable;
    }
    if (!mounted || attempt != _opening) {
      await camera.close();
      return;
    }
    if (next == _CameraState.ready) {
      _camera = camera;
    } else {
      await camera.close();
    }
    setState(() => _state = next);
  }

  Future<void> _takePicture() async {
    if (_camera == null) return;
    if (_taking) {
      _extraPresses++;
      return;
    }
    _taking = true;
    try {
      while (true) {
        final camera = _camera;
        if (camera == null || !mounted) break;
        final path = await camera.takePicture();
        final takenAt = ref.read(clockProvider)();
        ref.read(captureQueueProvider).add(_session, path, takenAt);
        if (mounted) setState(() => _flash = true);
        if (_extraPresses == 0) break;
        _extraPresses--;
      }
    } on Object {
      // Let the camera go before the hint, so "Noch einmal versuchen"
      // opens the only one (PR 69 B2).
      _extraPresses = 0;
      final camera = _camera;
      _camera = null;
      await camera?.close();
      if (mounted) setState(() => _state = _CameraState.unavailable);
    } finally {
      _taking = false;
    }
  }

  void _done() {
    if (context.canPop()) {
      context.pop();
    } else {
      final room = widget.roomId;
      final base = room == null
          ? '/customers/${widget.customerId}'
          : '/customers/${widget.customerId}/rooms/$room';
      final before = widget.afterOf;
      context.go(before == null ? base : '$base/pictures/$before');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _title(l10n);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: WioBackButton(label: l10n.cameraDone, onPressed: _done),
        leadingWidth: wioBackButtonWidth(context),
        title: Text(title),
      ),
      body: switch (_state) {
        _CameraState.ready => _Preview(
          camera: _camera!,
          overlay: _overlay(context),
          flash: _flash,
          onFlashEnd: () => setState(() => _flash = false),
        ),
        _CameraState.opening => const ColoredBox(color: Colors.black),
        _CameraState.denied => _Problem(
          lines: <String>[l10n.cameraDenied, l10n.cameraDeniedHelp],
          button: l10n.cameraAskAgain,
          onPressed: _open,
        ),
        _CameraState.unavailable => _Problem(
          lines: <String>[l10n.cameraUnavailable],
          button: l10n.cameraTryAgain,
          onPressed: _open,
        ),
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
                  for (final line in _status(l10n))
                    Text(
                      line,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  if (_state == _CameraState.ready) ...<Widget>[
                    const SizedBox(height: 12),
                    Semantics(
                      button: true,
                      label: l10n.cameraShutterLabel,
                      excludeSemantics: true,
                      child: SizedBox.square(
                        dimension: shutterSize,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size.square(shutterSize),
                          ),
                          onPressed: _takePicture,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(l10n.cameraShutter),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The before picture's file, or null when there is none to show.
  ImageProvider? _beforeImage(BuildContext context) {
    final before = _before();
    if (before == null) return null;
    final folder = ref.watch(mediaFolderProvider).value;
    final size = MediaQuery.sizeOf(context);
    return localPicture(
      folder,
      before.fileSha256,
      cacheWidth: (size.width * MediaQuery.devicePixelRatioOf(context)).round(),
    );
  }

  Picture? _before() {
    final id = widget.afterOf;
    if (id == null) return null;
    return ref
        .watch(
          pictureProvider((
            customerId: widget.customerId,
            roomId: widget.roomId,
            pictureId: id,
          )),
        )
        .value;
  }

  /// The before picture, faint, over the live image (D-277). Only drawn on
  /// the screen: the shot is the camera's own frame (D-276).
  Widget? _overlay(BuildContext context) {
    final image = _beforeImage(context);
    if (image == null) return null;
    return IgnorePointer(
      child: Opacity(
        key: const ValueKey<String>('after-overlay'),
        opacity: afterOverlayOpacity,
        child: Image(
          image: image,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  String _title(AppLocalizations l10n) {
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

  List<String> _status(AppLocalizations l10n) {
    final empty =
        _session.stored == 0 && _session.pending == 0 && _session.failed == 0;
    if (empty && _state != _CameraState.ready) return const <String>[];
    final folder = ref.watch(mediaFolderProvider);
    final after = <String>[
      // No hint while the media folder is not known yet (rule 7).
      if (widget.afterOf != null &&
          _state == _CameraState.ready &&
          (folder.hasValue || !folder.isLoading))
        // A missing before file is a hint, not a block (UX rule 7).
        _beforeImage(context) == null
            ? l10n.cameraAfterNoBefore
            : l10n.cameraAfterOverlay,
    ];
    return <String>[
      ...after,
      if (_session.stored == 0 && _session.pending == 0)
        l10n.cameraNoneYet
      else if (_session.stored > 0)
        l10n.cameraStored(_session.stored),
      if (_session.pending > 0) l10n.cameraSaving(_session.pending),
      if (_session.failed > 0) l10n.cameraFailed(_session.failed),
    ];
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.camera,
    required this.overlay,
    required this.flash,
    required this.onFlashEnd,
  });

  final CaptureCamera camera;
  final Widget? overlay;
  final bool flash;
  final VoidCallback onFlashEnd;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(child: camera.preview(overlay: overlay)),
          // A short white flash confirms each press; nothing to dismiss.
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: flash ? 0.7 : 0,
              duration: const Duration(milliseconds: 120),
              onEnd: () {
                if (flash) onFlashEnd();
              },
              child: const ColoredBox(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({
    required this.lines,
    required this.button,
    required this.onPressed,
  });

  final List<String> lines;
  final String button;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          for (final line in lines) HintText(line),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
            ),
            onPressed: onPressed,
            child: Text(button),
          ),
        ],
      ),
    );
  }
}
