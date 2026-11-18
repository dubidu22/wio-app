import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../auth/session.dart';
import '../auth/session_provider.dart';
import '../data/queries.dart';
import '../l10n/app_localizations.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';
import '../shell/router.dart';
import '../shell/source_link_button.dart';

/// Level 1, "Aufträge": today's and later jobs (KB workflows.md). Tapping a
/// job opens its customer. The "Quellcode" button sits top right (D-73).
/// Signed out, a plain hint with "Anmelden" sits on top and the list stays
/// usable (D-130); signed in, "Abmelden" sits at the end (D-132).
class JobListScreen extends ConsumerWidget {
  const JobListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final jobs = ref.watch(jobListProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.jobsTitle),
        actions: const <Widget>[SourceLinkButton(), SizedBox(width: 8)],
      ),
      // While the list reloads (for example at midnight) the last list
      // stays on screen.
      body: switch (jobs) {
        AsyncValue(:final error?) => LoadFailed(
          message: l10n.loadFailed,
          error: error,
        ),
        AsyncValue(:final value?) => _JobListBody(
          list: value,
          session: ref.watch(sessionProvider),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _JobListBody extends StatelessWidget {
  const _JobListBody({required this.list, required this.session});

  final JobList list;

  /// Loading shows neither the hint nor Abmelden.
  final AsyncValue<Session?> session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          if (session case AsyncData(value: null)) const _SignedOutHint(),
          SectionHeading(l10n.jobsToday),
          if (list.today.isEmpty)
            HintText(l10n.jobsTodayEmpty)
          else
            for (final job in list.today) _JobButton(job: job, showDate: false),
          SectionHeading(l10n.jobsUpcoming),
          if (list.upcoming.isEmpty)
            HintText(l10n.jobsUpcomingEmpty)
          else
            for (final job in list.upcoming)
              _JobButton(job: job, showDate: true),
          if (session case AsyncData(value: final Session signedIn))
            _SignOutFooter(session: signedIn),
        ],
      ),
    );
  }
}

/// One job: a full-width button with the customer's name (UX rules 1, 3).
class _JobButton extends StatelessWidget {
  const _JobButton({required this.job, required this.showDate});

  final JobListItem job;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(72),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: () => context.go('/customers/${job.customerId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              job.customerName ?? l10n.unnamedCustomer,
              style: theme.textTheme.titleLarge,
            ),
            if (showDate)
              Text(
                l10n.jobDate(DateTime.parse(job.date)),
                style: theme.textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}

/// Signed out (D-130): a plain hint and a labelled button, never a gate.
class _SignedOutHint extends StatelessWidget {
  const _SignedOutHint();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          HintText(l10n.signedOutHint),
          FilledButton(
            onPressed: () => context.go(signInLocation),
            child: Text(l10n.signInButton),
          ),
        ],
      ),
    );
  }
}

/// "Angemeldet als … bei …" and "Abmelden" at the end of the list (D-132).
class _SignOutFooter extends ConsumerWidget {
  const _SignOutFooter({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final workspace = session.workspace.name ?? l10n.unnamedWorkspace;
    final name = session.user.displayName;
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          HintText(
            name == null
                ? l10n.signedInAt(workspace)
                : l10n.signedInAs(name, workspace),
          ),
          OutlinedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(sessionProvider.notifier).signOut();
              messenger.showSnackBar(SnackBar(content: Text(l10n.signedOut)));
            },
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }
}
