import 'package:go_router/go_router.dart';

import '../camera/camera_screen.dart';
import '../entries/entry_screen.dart';
import '../entries/entry_title_screen.dart';
import '../pictures/picture_screen.dart';
import '../shell/task_routes.dart';
import 'place_screen.dart';
import 'spot_screen.dart';

/// The routes of the entry `/customers/:customerId/entries/:entryId` (D-451):
/// the entry screen (plan 103) and, as parts of the entry task, its place
/// and target pickers, title, camera, voice note, notes and pictures. The
/// entry is a task, not a fourth level.
GoRoute entryRoute() => GoRoute(
  path: 'entries/:entryId',
  builder: (context, state) => EntryScreen(
    customerId: state.pathParameters['customerId']!,
    entryId: state.pathParameters['entryId']!,
  ),
  routes: <RouteBase>[
    ...placeRoutes(),
    GoRoute(
      path: 'titel',
      builder: (context, state) => EntryTitleScreen(
        customerId: state.pathParameters['customerId']!,
        entryId: state.pathParameters['entryId']!,
      ),
    ),
    // The entry's photo camera, part of the entry task (D-468).
    GoRoute(
      path: 'kamera',
      builder: (context, state) => CameraScreen(
        customerId: state.pathParameters['customerId']!,
        entryId: state.pathParameters['entryId'],
      ),
    ),
    voiceRoute(),
    ...notesRoutes(),
    ...labelRoutes(),
    // A picture of the entry, with its after camera, voice note and notes.
    GoRoute(
      path: 'pictures/:pictureId',
      builder: (context, state) => PictureScreen(
        customerId: state.pathParameters['customerId']!,
        entryId: state.pathParameters['entryId'],
        pictureId: state.pathParameters['pictureId']!,
      ),
      routes: <RouteBase>[
        GoRoute(
          path: 'nachher',
          builder: (context, state) => CameraScreen(
            customerId: state.pathParameters['customerId']!,
            entryId: state.pathParameters['entryId'],
            afterOf: state.pathParameters['pictureId'],
          ),
        ),
        voiceRoute(),
        ...notesRoutes(),
      ],
    ),
  ],
);

/// The place and target pickers, part of the entry task, not a fourth level
/// (D-451, as D-261).
List<RouteBase> placeRoutes() => <RouteBase>[
  GoRoute(
    path: 'ort',
    builder: (context, state) => PlaceScreen(
      customerId: state.pathParameters['customerId']!,
      entryId: state.pathParameters['entryId']!,
      mode: PickMode.place,
    ),
    routes: <RouteBase>[
      GoRoute(
        path: ':roomId',
        builder: (context, state) => SpotScreen(
          customerId: state.pathParameters['customerId']!,
          entryId: state.pathParameters['entryId']!,
          roomId: state.pathParameters['roomId']!,
        ),
      ),
    ],
  ),
  GoRoute(
    path: 'ziel',
    builder: (context, state) => PlaceScreen(
      customerId: state.pathParameters['customerId']!,
      entryId: state.pathParameters['entryId']!,
      mode: PickMode.target,
    ),
  ),
];
