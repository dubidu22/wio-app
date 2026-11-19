import 'package:go_router/go_router.dart';

import '../auth/sign_in_screen.dart';
import '../customers/customer_screen.dart';
import '../jobs/job_list_screen.dart';
import '../pictures/picture_screen.dart';
import '../rooms/room_screen.dart';
import '../sync/rejected_screen.dart';
import '../update/update_required_screen.dart';

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
                  // Part of the room task, not a fourth level (D-261).
                  GoRoute(
                    path: 'pictures/:pictureId',
                    builder: (context, state) => PictureScreen(
                      customerId: state.pathParameters['customerId']!,
                      roomId: state.pathParameters['roomId'],
                      pictureId: state.pathParameters['pictureId']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'pictures/:pictureId',
                builder: (context, state) => PictureScreen(
                  customerId: state.pathParameters['customerId']!,
                  pictureId: state.pathParameters['pictureId']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
