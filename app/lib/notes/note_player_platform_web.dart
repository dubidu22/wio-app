import '../media/media_store.dart';
import 'note_player.dart';
import 'note_player_web.dart';

/// The web's player from memory (D-335).
NotePlayer platformNotePlayer(MediaStore store) => WebNotePlayer(store);
