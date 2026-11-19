import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import '../media/media_store.dart';
import 'note_audio_web.dart';
import 'note_player.dart';

/// The web's player (D-335): an `<audio>` element playing a blob URL of
/// the recording kept in memory (D-334). The URL is given up on stop, end
/// and error; the token never leaves the request header.
class WebNotePlayer implements NotePlayer {
  WebNotePlayer(this._store);

  final MediaStore _store;
  final ValueNotifier<NotePlayback> _playback = ValueNotifier<NotePlayback>(
    NotePlayback.idle,
  );
  web.HTMLAudioElement? _audio;
  String? _url;
  int _token = 0;

  @override
  ValueListenable<NotePlayback> get playback => _playback;

  @override
  Future<void> play(String noteId, String path) async {
    _release();
    final token = ++_token;
    final bytes = path.startsWith(webMemoryPrefix)
        ? _store.bytesOf(path.substring(webMemoryPrefix.length))
        : null;
    if (bytes == null) {
      _playback.value = NotePlayback(failed: noteId);
      return;
    }
    _playback.value = NotePlayback(noteId: noteId);
    final url = web.URL.createObjectURL(
      web.Blob(
        <JSAny>[bytes.toJS].toJS,
        web.BlobPropertyBag(type: 'audio/mp4'),
      ),
    );
    final audio = web.HTMLAudioElement()..src = url;
    _audio = audio;
    _url = url;
    void on(String type, void Function() handler) {
      audio.addEventListener(
        type,
        ((web.Event _) {
          if (token == _token) handler();
        }).toJS,
      );
    }

    on('timeupdate', () {
      _playback.value = NotePlayback(
        noteId: noteId,
        position: Duration(milliseconds: (audio.currentTime * 1000).round()),
      );
    });
    on('ended', () {
      _release();
      _playback.value = NotePlayback.idle;
    });
    on('error', () {
      _release();
      _playback.value = NotePlayback(failed: noteId);
    });
    try {
      await audio.play().toDart;
    } on Object catch (error) {
      debugPrint('wio web player: $error');
      if (token != _token) return;
      _release();
      _playback.value = NotePlayback(failed: noteId);
    }
  }

  @override
  Future<void> stop() async {
    if (_playback.value.noteId == null) return;
    _token++;
    _release();
    _playback.value = NotePlayback.idle;
  }

  void _release() {
    final audio = _audio;
    if (audio != null) {
      audio.pause();
      audio.removeAttribute('src');
    }
    final url = _url;
    if (url != null) web.URL.revokeObjectURL(url);
    _audio = null;
    _url = null;
  }
}
