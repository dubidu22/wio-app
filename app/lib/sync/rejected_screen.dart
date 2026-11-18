import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'rejected_changes.dart';

/// Path of the list of refused changes (D-197).
const String rejectedLocation = '/nicht-gesendet';

/// "Nicht gesendet" (D-197): every change the server refused, with what it
/// did and why, so nothing is lost silently. "Noch einmal senden" makes a
/// new change; "Verwerfen" removes the entry, with "Rückgängig".
class RejectedScreen extends ConsumerWidget {
  const RejectedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final list = ref.watch(rejectedListProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const WioBackButton(),
        leadingWidth: wioBackButtonWidth(context),
        title: Text(l10n.rejectedTitle),
      ),
      body: switch (list) {
        AsyncValue(:final error?) => LoadFailed(
          message: l10n.loadFailed,
          error: error,
        ),
        AsyncValue(:final value?) => ContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: <Widget>[
              if (value.isEmpty) HintText(l10n.rejectedEmpty),
              for (final entry in value) _RejectedTile(entry: entry),
            ],
          ),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _RejectedTile extends ConsumerWidget {
  const _RejectedTile({required this.entry});

  final RejectedEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final change = entry.change;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.rejectedRecord(
                  _kind(l10n, change.entity),
                  entry.name ?? l10n.rejectedUnnamed,
                ),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(_what(l10n, entry), style: theme.textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text(
                _why(l10n, change.reason, change.existingId),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: <Widget>[
                  if (entry.canResend)
                    FilledButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await resendRejected(
                          ref.read(databaseProvider),
                          change,
                          now: ref.read(clockProvider)(),
                        );
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n.rejectedRetried)),
                        );
                      },
                      child: Text(l10n.rejectedRetry),
                    ),
                  OutlinedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final db = ref.read(databaseProvider);
                      await discardRejected(db, change);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.rejectedDiscarded),
                          // UX rule 9: the note goes by itself; an action
                          // would otherwise keep it on screen.
                          duration: const Duration(seconds: 8),
                          persist: false,
                          action: SnackBarAction(
                            label: l10n.undo,
                            onPressed: () => keepRejected(db, change),
                          ),
                        ),
                      );
                    },
                    child: Text(l10n.rejectedDiscard),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _kind(AppLocalizations l10n, String entity) => switch (entity) {
  'customers' => l10n.entityCustomer,
  'sites' => l10n.entitySite,
  'rooms' => l10n.entityRoom,
  'jobs' => l10n.entityJob,
  _ => l10n.entityOther,
};

String _what(AppLocalizations l10n, RejectedEntry entry) {
  final change = entry.change;
  switch (change.op) {
    case 'delete':
      return l10n.rejectedDeletedOp;
    case 'restore':
      return l10n.rejectedRestoredOp;
  }
  final fields = entry.fields;
  if (fields.containsKey('workspace_id')) return l10n.rejectedCreated;
  final names = <String>{for (final key in fields.keys) _field(l10n, key)}
      .toList();
  return l10n.rejectedChanged(names.join(', '));
}

String _field(AppLocalizations l10n, String key) => switch (key) {
  'name' => l10n.fieldName,
  'contact' => l10n.fieldContact,
  'external_ref' => l10n.fieldExternalRef,
  'address' => l10n.fieldAddress,
  'outline' => l10n.fieldOutline,
  'height_cm' => l10n.fieldHeight,
  'date' => l10n.fieldDate,
  'agreed_minutes' => l10n.fieldAgreedMinutes,
  'report_sent_at' => l10n.fieldReportSent,
  'customer_id' => l10n.fieldCustomer,
  'site_id' => l10n.fieldSite,
  _ => l10n.fieldOther,
};

String _why(AppLocalizations l10n, String reason, String? existingId) =>
    switch (reason) {
      'permission' => l10n.rejectedPermission,
      'deleted' => l10n.rejectedDeleted,
      'duplicate' when existingId != null => l10n.rejectedDuplicate,
      'duplicate' => l10n.rejectedDuplicateValue,
      'invalid' => l10n.rejectedInvalid,
      'not_found' => l10n.rejectedNotFound,
      'too_large' => l10n.rejectedTooLarge,
      _ => l10n.rejectedOther,
    };
