import 'package:go_router/go_router.dart';

import '../auth/sign_in_screen.dart';
import '../camera/camera_screen.dart';
import '../customers/customer_screen.dart';
import '../jobs/job_list_screen.dart';
import '../notes/note_screen.dart';
import '../pictures/picture_screen.dart';
import '../planning/place_routes.dart';
import '../rooms/room_screen.dart';
import '../scan/scan_screen.dart';
import '../sync/rejected_screen.dart';
import '../update/update_required_screen.dart';
import '../voice/voice_screen.dart';

/// Path of the sign-in screen (D-126).
const String signInLocation = '/anmelden';

/// Routes of the app (D-69, D-259). The customer, sign-in and update routes are
/// nested under the job list, so a link straight to them still has "Zurück"
/// to the list.
GoRouter buildRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    // An unknown address shows the job list rather than an error page.
    errorBuilder: (context, state) => const JobListScreen(),
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const JobListScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'anmelden',
            builder: (context, state) => const SignInScreen(),
          ),
          GoRoute(
            path: 'nicht-gesendet',
            builder: (context, state) => const RejectedScreen(),
          ),
          GoRoute(
            path: 'aktualisieren',
            builder: (context, state) => const UpdateRequiredScreen(),
          ),
          GoRoute(
            path: 'customers/:customerId',
            builder: (context, state) =>
                CustomerScreen(customerId: state.pathParameters['customerId']!),
            routes: <RouteBase>[
              GoRoute(
                path: 'rooms/:roomId',
                builder: (context, state) => RoomScreen(
                  customerId: state.pathParameters['customerId']!,
                  roomId: state.pathParameters['roomId']!,
                ),
                routes: <RouteBase>[
                  // Part of the room task, not a fourth level (D-271).
                  GoRoute(
                    path: 'kamera',
                    builder: (context, state) => CameraScreen(
                      customerId: state.pathParameters['customerId']!,
                      roomId: state.pathParameters['roomId'],
                    ),
                  ),
                  _voiceRoute(),
                  ..._notesRoutes(),
                  // "+ Eintrag" from the room (D-468).
                  GoRoute(
                    path: 'eintrag',
                    builder: (context, state) => ScanScreen(
                      customerId: state.pathParameters['customerId']!,
                      roomId: state.pathParameters['roomId'],
                    ),
                  ),
                  // Part of the room task, not a fourth level (D-261).
                  GoRoute(
                    path: 'pictures/:pictureId',
                    builder: (context, state) => PictureScreen(
                      customerId: state.pathParameters['customerId']!,
                      roomId: state.pathParameters['roomId'],
                      pictureId: state.pathParameters['pictureId']!,
                    ),
                    routes: <RouteBase>[
                      // The after camera, part of the same task (D-276).
                      GoRoute(
                        path: 'nachher',
                        builder: (context, state) => CameraScreen(
                          customerId: state.pathParameters['customerId']!,
                          roomId: state.pathParameters['roomId'],
                          afterOf: state.pathParameters['pictureId'],
                        ),
                      ),
                      _voiceRoute(),
                      ..._notesRoutes(),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: 'pictures/:pictureId',
                builder: (context, state) => PictureScreen(
                  customerId: state.pathParameters['customerId']!,
                  pictureId: state.pathParameters['pictureId']!,
                ),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'nachher',
                    builder: (context, state) => CameraScreen(
                      customerId: state.pathParameters['customerId']!,
                      afterOf: state.pathParameters['pictureId'],
                    ),
                  ),
                  _voiceRoute(),
                  ..._notesRoutes(),
                ],
              ),
              // An entry and its place pickers (D-451).
              entryRoute(),
              // "+ Eintrag" from the customer (D-468).
              GoRoute(
                path: 'eintrag',
                builder: (context, state) =>
                    ScanScreen(customerId: state.pathParameters['customerId']!),
              ),
              // Pictures without a room (Q3, D-271).
              GoRoute(
                path: 'kamera',
                builder: (context, state) => CameraScreen(
                  customerId: state.pathParameters['customerId']!,
                ),
              ),
              _voiceRoute(),
              ..._notesRoutes(),
            ],
          ),
        ],
      ),
    ],
  );
}

/// The voice note under a customer, room or picture: part of that task, not
/// a level of its own (D-295, as D-271). Its subject is the picture, else
/// the room, else the customer.
GoRoute _voiceRoute() => GoRoute(
  path: 'sprechen',
  builder: (context, state) => VoiceScreen(
    customerId: state.pathParameters['customerId']!,
    roomId: state.pathParameters['roomId'],
    pictureId: state.pathParameters['pictureId'],
  ),
);

/// The note screens under a customer, room or picture: a new text note and
/// one note, part of that task (D-299, as D-271).
List<GoRoute> _notesRoutes() => <GoRoute>[
  GoRoute(
    path: 'notizen/neu',
    builder: (context, state) => NoteScreen(
      customerId: state.pathParameters['customerId']!,
      roomId: state.pathParameters['roomId'],
      pictureId: state.pathParameters['pictureId'],
    ),
  ),
  GoRoute(
    path: 'notizen/:noteId',
    builder: (context, state) => NoteScreen(
      customerId: state.pathParameters['customerId']!,
      roomId: state.pathParameters['roomId'],
      pictureId: state.pathParameters['pictureId'],
      noteId: state.pathParameters['noteId'],
    ),
  ),
];
