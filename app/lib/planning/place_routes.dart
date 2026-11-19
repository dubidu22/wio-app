import 'package:go_router/go_router.dart';

import 'place_screen.dart';
import 'spot_screen.dart';

/// The routes of the entry `/customers/:customerId/entries/:entryId` (D-451).
///
/// Until the entry screen exists (#103), the entry's own address shows the
/// customer screen; #103 replaces the redirect with its builder and adds
/// the "Ort ändern" and "Ziel" buttons (plan 107, C1). No button leads here
/// before that (D-75).
GoRoute entryRoute() => GoRoute(
  path: 'entries/:entryId',
  redirect: (context, state) {
    final customerId = state.pathParameters['customerId']!;
    final entryId = state.pathParameters['entryId']!;
    return state.uri.path == entryLocation(customerId, entryId)
        ? '/customers/$customerId'
        : null;
  },
  routes: placeRoutes(),
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
