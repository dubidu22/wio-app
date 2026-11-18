import 'package:go_router/go_router.dart';

import '../auth/sign_in_screen.dart';
import '../customers/customer_screen.dart';
import '../jobs/job_list_screen.dart';

/// Path of the sign-in screen (D-126).
const String signInLocation = '/anmelden';

/// Routes of the app (D-69). The customer and sign-in routes are nested
/// under the job list, so a link straight to them still has "Zurück" to the
/// list.
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
            path: 'customers/:customerId',
            builder: (context, state) =>
                CustomerScreen(customerId: state.pathParameters['customerId']!),
          ),
        ],
      ),
    ],
  );
}
