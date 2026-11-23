import 'package:go_router/go_router.dart';

import '../entries/label_new_screen.dart';
import '../entries/property_screen.dart';
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

/// The label and property screens of an entry: part of the entry task, not a
/// level (plan 104). `eigenschaft/neu` comes before `eigenschaft/:keyId`.
List<GoRoute> labelRoutes() => <GoRoute>[
  GoRoute(
    path: 'label',
    builder: (context, state) => LabelNewScreen(
      customerId: state.pathParameters['customerId']!,
      entryId: state.pathParameters['entryId']!,
    ),
  ),
  GoRoute(
    path: 'eigenschaft/neu',
    builder: (context, state) => PropertyScreen(
      customerId: state.pathParameters['customerId']!,
      entryId: state.pathParameters['entryId']!,
    ),
  ),
  GoRoute(
    path: 'eigenschaft/:keyId',
    builder: (context, state) => PropertyScreen(
      customerId: state.pathParameters['customerId']!,
      entryId: state.pathParameters['entryId']!,
      keyId: state.pathParameters['keyId'],
    ),
  ),
];
