import 'package:go_router/go_router.dart';

import '../notes/note_screen.dart';
import '../voice/voice_screen.dart';

/// The voice note under a customer, room, entry or picture: part of that
/// task, not a level of its own (D-295, as D-271). Its subject is the
/// picture, else the entry, else the room, else the customer.
GoRoute voiceRoute() => GoRoute(
  path: 'sprechen',
  builder: (context, state) => VoiceScreen(
    customerId: state.pathParameters['customerId']!,
    roomId: state.pathParameters['roomId'],
    entryId: state.pathParameters['entryId'],
    pictureId: state.pathParameters['pictureId'],
  ),
);

/// The note screens under a customer, room, entry or picture: a new text note and
/// one note, part of that task (D-299, as D-271).
List<GoRoute> notesRoutes() => <GoRoute>[
  GoRoute(
    path: 'notizen/neu',
    builder: (context, state) => NoteScreen(
      customerId: state.pathParameters['customerId']!,
      roomId: state.pathParameters['roomId'],
      entryId: state.pathParameters['entryId'],
      pictureId: state.pathParameters['pictureId'],
    ),
  ),
  GoRoute(
    path: 'notizen/:noteId',
    builder: (context, state) => NoteScreen(
      customerId: state.pathParameters['customerId']!,
      roomId: state.pathParameters['roomId'],
      entryId: state.pathParameters['entryId'],
      pictureId: state.pathParameters['pictureId'],
      noteId: state.pathParameters['noteId'],
    ),
  ),
];
