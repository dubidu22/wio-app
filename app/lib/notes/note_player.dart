import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// What the player is doing: which note plays and how far it is, or which
/// note failed to play (D-300, D-301).
@immutable
class NotePlayback {
  const NotePlayback({this.noteId, this.position = Duration.zero, this.failed});

  /// The note playing now, or null.
  final String? noteId;
  final Duration position;

  /// The note whose last start failed, for a plain hint (rule 7).
  final String? failed;

  static const NotePlayback idle = NotePlayback();

  @override
  bool operator ==(Object other) =>
      other is NotePlayback &&
      other.noteId == noteId &&
      other.position == position &&
      other.failed == failed;

  @override
  int get hashCode => Object.hash(noteId, position, failed);
}

/// Plays one note's recording at a time (D-301). Tests use a fake.
abstract class NotePlayer {
  ValueListenable<NotePlayback> get playback;

  /// Plays the recording of note [noteId] from the local file at [path];
  /// stops whatever played before.
  Future<void> play(String noteId, String path);

  /// Stops playing; does nothing when nothing plays.
  Future<void> stop();
}

/// The app's own Android code on channel `wio/player` (D-300): MediaPlayer
/// from a local file. Events `onPosition(millis)`, `onEnded`, `onError`.
class ChannelNotePlayer implements NotePlayer {
  ChannelNotePlayer([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('wio/player') {
    _channel.setMethodCallHandler(_onCall);
  }

  final MethodChannel _channel;
  final ValueNotifier<NotePlayback> _playback = ValueNotifier<NotePlayback>(
    NotePlayback.idle,
  );

  @override
  ValueListenable<NotePlayback> get playback => _playback;

  Future<Object?> _onCall(MethodCall call) async {
    final current = _playback.value.noteId;
    if (current == null) return null;
    switch (call.method) {
      case 'onPosition':
        _playback.value = NotePlayback(
          noteId: current,
          position: Duration(milliseconds: call.arguments as int? ?? 0),
        );
      case 'onEnded':
        _playback.value = NotePlayback.idle;
      case 'onError':
        _playback.value = NotePlayback(failed: current);
    }
    return null;
  }

  @override
  Future<void> play(String noteId, String path) async {
    _playback.value = NotePlayback(noteId: noteId);
    try {
      await _channel.invokeMethod<void>('play', <String, Object>{'path': path});
    } on Exception catch (error) {
      // PlatformException, or no player in this build.
      debugPrint('wio player: $error');
      _playback.value = NotePlayback(failed: noteId);
    }
  }

  @override
  Future<void> stop() async {
    if (_playback.value.noteId == null) return;
    _playback.value = NotePlayback.idle;
    await _channel.invokeMethod<void>('stop');
  }
}
