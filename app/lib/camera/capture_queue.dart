import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/media_writer.dart';
import 'capture_files.dart';
import 'picture_processor.dart';

/// Where new pictures go: a room of a customer, or the customer itself
/// when [roomId] is null (customer screen "Fotos", Q3).
typedef CaptureTarget = ({String customerId, String? roomId});

/// What one opening of the camera has done so far; the camera screen
/// shows it (D-268).
class CaptureSession extends ChangeNotifier {
  CaptureSession(this.target);

  final CaptureTarget target;
  int _stored = 0;
  int _pending = 0;
  int _failed = 0;

  /// Pictures saved for good (row, outbox and upload written).
  int get stored => _stored;

  /// Shots taken but still being prepared.
  int get pending => _pending;

  /// Shots that could not be saved.
  int get failed => _failed;

  void _update(void Function() change) {
    change();
    notifyListeners();
  }
}

/// Turns shots into stored pictures, one at a time, in press order (D-268).
///
/// It lives as long as the app, not the camera screen, so leaving the
/// camera never loses a shot that is still being prepared. Only the
/// prepared file, stripped of all metadata (D-267), reaches
/// [MediaWriter.addPicture] and so the media folder and the upload queue.
class CaptureQueue {
  CaptureQueue({
    required this._db,
    required this._writer,
    required this._files,
    this._prepare = preparePicture,
  });

  final WioDatabase _db;
  final MediaWriter _writer;
  final CaptureFiles _files;
  final PictureProcessor _prepare;
  Future<void> _tail = Future<void>.value();
  final DateTime _started = DateTime.now();
  int _waiting = 0;

  /// Whether shots are still waiting to be stored.
  bool get busy => _waiting > 0;

  /// Completes when every shot added so far is stored or has failed.
  Future<void> get idle => _tail;

  /// Takes over the camera's shot at [shotPath], taken at [takenAt]
  /// (D-273), and stores it in the background.
  void add(CaptureSession session, String shotPath, DateTime takenAt) {
    _waiting++;
    session._update(() => session._pending++);
    final moved = _files.takeOver(shotPath);
    _tail = _tail.then((_) => _store(session, moved, takenAt));
  }

  Future<void> _store(
    CaptureSession session,
    Future<String> moved,
    DateTime takenAt,
  ) async {
    String? shot;
    String? prepared;
    var ok = false;
    try {
      shot = await moved;
      final picture = await _prepare(await _files.read(shot));
      prepared = await _files.write(picture.bytes);
      final customer = await (_db.select(
        _db.customers,
      )..where((c) => c.id.equals(session.target.customerId))).getSingle();
      await _writer.addPicture(
        workspaceId: customer.workspaceId,
        file: PreparedPicture(
          path: prepared,
          mime: 'image/jpeg',
          widthPx: picture.widthPx,
          heightPx: picture.heightPx,
          takenAt: takenAt,
        ),
        roomId: session.target.roomId,
        customerId: session.target.customerId,
      );
      ok = true;
    } on Object catch (error) {
      // Counted as failed on the camera screen; the log helps hand tests.
      debugPrint('wio camera: picture not stored: $error');
    } finally {
      for (final path in <String?>[shot, prepared]) {
        if (path != null) {
          try {
            await _files.delete(path);
          } on Object {
            // The start-up sweep takes it (D-268).
          }
        }
      }
      _waiting--;
      session._update(() {
        session._pending--;
        if (ok) {
          session._stored++;
        } else {
          session._failed++;
        }
      });
    }
  }

  /// Deletes shots left over from an earlier run (D-268); shots of this
  /// run are newer than the queue and stay.
  Future<void> sweep() => _files.sweep(before: _started);
}
