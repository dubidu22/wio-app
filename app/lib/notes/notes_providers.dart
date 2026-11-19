import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/queries.dart';
import '../media/media_store.dart';
import '../shell/providers.dart';
import 'note_audio.dart';
import 'note_player.dart';

/// What notes are about on a screen: subject type and id (D-298).
typedef NoteSubject = ({String type, String id});

/// The subject of a screen under [customerId]: the picture, else the room,
/// else the customer (as the voice note, D-295).
NoteSubject noteSubjectOf({
  required String customerId,
  String? roomId,
  String? pictureId,
}) {
  if (pictureId != null) return (type: 'picture', id: pictureId);
  if (roomId != null) return (type: 'room', id: roomId);
  return (type: 'customer', id: customerId);
}

/// Live notes of a subject, oldest first (D-245, D-298).
final notesProvider = StreamProvider.family<List<Note>, NoteSubject>(
  retry: (count, error) => null,
  (ref, subject) =>
      watchNotesOf(ref.watch(databaseProvider), subject.type, subject.id),
);

/// One live note, or null when it is gone.
final noteProvider = StreamProvider.family<Note?, String>(
  retry: (count, error) => null,
  (ref, id) => watchNote(ref.watch(databaseProvider), id),
);

/// The local path of a recording, or null when it is not on the device
/// (D-305). #62 invalidates it after a download.
final noteAudioProvider = Provider.family<String?, String>(
  (ref, sha256) => localNoteAudio(ref.watch(mediaFolderProvider).value, sha256),
);

/// The phone's player (D-300). Tests override it with a fake.
final notePlayerProvider = Provider<NotePlayer>((ref) => ChannelNotePlayer());

/// Whether this build plays recordings (D-300): Android only, where the
/// media store keeps files. The web gets its player with #62, iOS with #63.
final canPlayNotesProvider = Provider<bool>(
  (ref) =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      ref.watch(mediaStoreProvider).supported,
);
