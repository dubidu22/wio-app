import 'package:go_router/go_router.dart';

import '../customers/customer_screen.dart';
import '../jobs/job_list_screen.dart';

/// Routes of the app (D-69). The customer route is nested under the job
/// list, so a link straight to a customer still has "Zurück" to the list.
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
            path: 'customers/:customerId',
            builder: (context, state) =>
                CustomerScreen(customerId: state.pathParameters['customerId']!),
          ),
        ],
      ),
    ],
  );
}
