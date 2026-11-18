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
import '../sync/rejected_screen.dart';
import '../sync/sync_runner.dart';
import '../update/app_too_old.dart';
import '../update/update_required_screen.dart';

/// Level 1, "Aufträge": today's and later jobs (KB workflows.md). Tapping a
/// job opens its customer. The "Quellcode" button sits top right (D-73).
/// Signed out, a plain hint with "Anmelden" sits on top and the list stays
/// usable (D-130); signed in, "Abmelden" sits at the end (D-132). While the
/// app is too old, the update hint takes the top instead (D-155). Refused
/// changes add a hint with "Ansehen" (D-197); a status line says what is
/// still on the phone (D-203).
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
          tooOld: ref.watch(appTooOldProvider) != null,
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _JobListBody extends StatelessWidget {
  const _JobListBody({
    required this.list,
    required this.session,
    required this.tooOld,
  });

  final JobList list;

  /// The update hint replaces the signed-out hint (D-155).
  final bool tooOld;

  /// Loading shows neither the hint nor Abmelden.
  final AsyncValue<Session?> session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          if (tooOld)
            const _UpdateHint()
          else if (session case AsyncData(value: null))
            const _SignedOutHint(),
          const _RejectedHint(),
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
          const _SyncStatusLine(),
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

/// Refused changes (D-197): a plain hint and "Ansehen" while any are listed.
class _RejectedHint extends ConsumerWidget {
  const _RejectedHint();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(rejectedCountProvider).value ?? 0;
    if (count == 0) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          HintText(l10n.rejectedHint(count)),
          OutlinedButton(
            onPressed: () => context.go(rejectedLocation),
            child: Text(l10n.rejectedOpen),
          ),
        ],
      ),
    );
  }
}

/// What sync is doing and what is still on the phone (D-203). No button:
/// sync runs by itself (D-201).
class _SyncStatusLine extends ConsumerWidget {
  const _SyncStatusLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pending = ref.watch(outboxCountProvider).value;
    if (pending == null) return const SizedBox.shrink();
    final text = switch (ref.watch(syncProvider)) {
      SyncActivity.running => l10n.syncRunning,
      SyncActivity.offline when pending > 0 => l10n.syncOffline,
      _ when pending > 0 => l10n.syncPending(pending),
      _ => l10n.syncAllSent,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Semantics(liveRegion: true, child: HintText(text)),
    );
  }
}

/// Too old (D-155): a plain hint and "App aktualisieren", never a gate.
class _UpdateHint extends StatelessWidget {
  const _UpdateHint();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          HintText(l10n.updateHint),
          UpdateButton(
            onNotOpened: (uri) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.updateLinkFallback(uri.toString()))),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Angemeldet als … bei …" and "Abmelden" at the end of the list (D-132).
/// While signing out the button says "Abmelden …" and ignores taps (D-75).
class _SignOutFooter extends ConsumerStatefulWidget {
  const _SignOutFooter({required this.session});

  final Session session;

  @override
  ConsumerState<_SignOutFooter> createState() => _SignOutFooterState();
}

class _SignOutFooterState extends ConsumerState<_SignOutFooter> {
  bool _busy = false;

  Future<void> _signOut() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(sessionProvider.notifier).signOut();
    messenger.showSnackBar(SnackBar(content: Text(l10n.signedOut)));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final workspace = widget.session.workspace.name ?? l10n.unnamedWorkspace;
    final name = widget.session.user.displayName;
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
            onPressed: _signOut,
            child: Text(_busy ? l10n.signOutSending : l10n.signOut),
          ),
        ],
      ),
    );
  }
}
