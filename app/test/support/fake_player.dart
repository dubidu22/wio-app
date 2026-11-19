import 'package:flutter/foundation.dart';
import 'package:wio_app/notes/note_player.dart';

/// A player for widget tests (plan 061): remembers what it was asked to
/// play and lets the test move the position, end or fail playback.
class FakeNotePlayer implements NotePlayer {
  final ValueNotifier<NotePlayback> _playback = ValueNotifier<NotePlayback>(
    NotePlayback.idle,
  );

  /// Paths asked to play, in order.
  final List<String> played = <String>[];
  int stops = 0;

  /// When set, [play] fails as the phone's player would.
  bool fail = false;

  @override
  ValueListenable<NotePlayback> get playback => _playback;

  @override
  Future<void> play(String noteId, String path) async {
    played.add(path);
    _playback.value = fail
        ? NotePlayback(failed: noteId)
        : NotePlayback(noteId: noteId);
  }

  @override
  Future<void> stop() async {
    if (_playback.value.noteId == null) return;
    stops++;
    _playback.value = NotePlayback.idle;
  }

  /// The phone reports how far it is.
  void at(Duration position) {
    final id = _playback.value.noteId;
    if (id != null) {
      _playback.value = NotePlayback(noteId: id, position: position);
    }
  }

  /// The recording reached its end.
  void end() => _playback.value = NotePlayback.idle;
}
