import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../media/local_picture.dart';
import '../media/media_presence.dart';
import '../media/media_store.dart';
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'rejected_changes.dart';
import 'sync_runner.dart';
import 'upload_queue.dart';

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
    final uploads = ref.watch(failedUploadsProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const WioBackButton(),
        leadingWidth: wioBackButtonWidth(context),
        title: Text(l10n.rejectedTitle),
      ),
      body: switch ((list, uploads)) {
        (AsyncValue(:final error?), _) || (_, AsyncValue(:final error?)) =>
          LoadFailed(message: l10n.loadFailed, error: error),
        (AsyncValue(value: final changes?), AsyncValue(value: final files?)) =>
          ContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: <Widget>[
                if (changes.isEmpty && files.isEmpty)
                  HintText(l10n.rejectedEmpty),
                for (final entry in changes) _RejectedTile(entry: entry),
                for (final file in files) _UploadTile(failed: file),
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

/// A failed upload (D-214): what it is and where it belongs, with a
/// thumbnail for a picture on this device (D-386, D-387); "Noch einmal
/// senden" only after a refused permission; "Verwerfen" with "Rückgängig"
/// (UX rule 10).
class _UploadTile extends ConsumerWidget {
  const _UploadTile({required this.failed});

  final FailedUpload failed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final upload = failed.upload;
    final size = megabytes(upload.size);
    final kind = switch (failed.kind) {
      UploadKind.picture => l10n.uploadKindPicture,
      UploadKind.voice => l10n.uploadKindVoice,
      UploadKind.unknown => null,
    };
    final title = Text(
      kind == null
          ? l10n.uploadTitle(size)
          : l10n.rejectedRecord(kind, failed.place ?? l10n.rejectedUnnamed),
      style: theme.textTheme.titleMedium,
    );
    final thumbnail = failed.kind == UploadKind.picture
        ? _thumbnail(context, ref, upload.sha256)
        : null;
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
              if (thumbnail == null)
                title
              else
                Row(
                  children: <Widget>[
                    thumbnail,
                    const SizedBox(width: 12),
                    Expanded(child: title),
                  ],
                ),
              const SizedBox(height: 4),
              Text(
                kind == null
                    ? l10n.uploadNotSent
                    : l10n.uploadNotSentSize(size),
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                _uploadWhy(l10n, upload.failedReason),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: <Widget>[
                  if (upload.failedReason == UploadFailure.permission)
                    FilledButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await retryUpload(ref.read(databaseProvider), upload);
                        ref.read(syncProvider.notifier).trigger();
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
                      await discardUpload(db, upload);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.rejectedDiscarded),
                          // UX rule 9, as for refused changes.
                          duration: const Duration(seconds: 8),
                          persist: false,
                          action: SnackBarAction(
                            label: l10n.undo,
                            onPressed: () => keepUpload(db, upload),
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

/// Side of the thumbnail of a failed picture (D-387).
const double _thumbnailSide = 72;

/// The picture file [sha256] as a small square, when it is on this device
/// (D-332); null otherwise. Not a button, and the title says what it is.
Widget? _thumbnail(BuildContext context, WidgetRef ref, String sha256) {
  if (ref.watch(mediaFileProvider(sha256)) != MediaFileState.present) {
    return null;
  }
  final image = localPicture(
    ref.watch(mediaStoreProvider),
    ref.watch(mediaFolderProvider).value,
    sha256,
    cacheWidth: (_thumbnailSide * MediaQuery.devicePixelRatioOf(context))
        .round(),
  );
  if (image == null) return null;
  return ExcludeSemantics(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image(
        image: image,
        width: _thumbnailSide,
        height: _thumbnailSide,
        fit: BoxFit.cover,
      ),
    ),
  );
}

/// A size in MB with one decimal, German style ("1,2 MB").
String megabytes(int bytes) =>
    '${NumberFormat('0.0', 'de').format(bytes / (1024 * 1024))} MB';

String _uploadWhy(AppLocalizations l10n, String? reason) => switch (reason) {
  UploadFailure.permission => l10n.uploadPermission,
  UploadFailure.tooLarge => l10n.uploadTooLarge,
  UploadFailure.invalid => l10n.uploadInvalid,
  _ => l10n.uploadDamaged,
};

String _kind(AppLocalizations l10n, String entity) => switch (entity) {
  'customers' => l10n.entityCustomer,
  'sites' => l10n.entitySite,
  'rooms' => l10n.entityRoom,
  'jobs' => l10n.entityJob,
  'entries' => l10n.entityEntry,
  'labels' => l10n.entityLabel,
  'property_keys' => l10n.entityPropertyKey,
  'entity_labels' => l10n.entityLabelLink,
  'entity_properties' => l10n.entityPropertyValue,
  _ => l10n.entityOther,
};

String _what(AppLocalizations l10n, RejectedEntry entry) {
  final change = entry.change;
  switch (change.op) {
    case 'delete':
      return l10n.rejectedDeletedOp;
    case 'restore':
      return l10n.rejectedRestoredOp;
    case 'move_entry':
      return l10n.rejectedMovedOp;
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
  'code' => l10n.fieldCode,
  'title' => l10n.fieldTitle,
  'room_id' ||
  'fixture_id' ||
  'level' ||
  'compartment' ||
  'floor_x_cm' ||
  'floor_y_cm' => l10n.fieldPlace,
  final target when target.startsWith('target_') => l10n.fieldTarget,
  'unit' => l10n.fieldUnit,
  'value_text' || 'value_number' => l10n.fieldValue,
  'label_id' => l10n.entityLabel,
  'key_id' => l10n.entityPropertyKey,
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
