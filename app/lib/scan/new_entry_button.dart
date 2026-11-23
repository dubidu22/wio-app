import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../camera/camera_providers.dart';
import '../l10n/app_localizations.dart';
import '../planning/place_screen.dart' show entryLocation;
import '../shell/providers.dart';
import 'new_entry.dart';
import 'scan_screen.dart';

/// **+ Eintrag** in the "Einträge" section of the customer and room
/// screens (D-465): a secondary full-width button; **Fotos** stays the main
/// one. It opens the scan screen at once (UX rule 5). Where the app takes
/// no pictures (the web, D-274) it does not scan (D-433): it creates an
/// entry without a code and opens it.
class NewEntryButton extends ConsumerStatefulWidget {
  const NewEntryButton({required this.from, super.key});

  final NewEntryFrom from;

  @override
  ConsumerState<NewEntryButton> createState() => _NewEntryButtonState();
}

class _NewEntryButtonState extends ConsumerState<NewEntryButton> {
  bool _busy = false;

  Future<void> _withoutScan() async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).scanFailed;
    try {
      final found = await findOrCreateEntry(
        ref.read(databaseProvider),
        ref.read(entryWriterProvider),
        widget.from,
      );
      if (mounted) context.go(entryLocation(found.customerId, found.entryId));
    } on ArgumentError {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scans = ref.watch(canTakePicturesProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(64)),
        onPressed: scans
            ? () => context.go(scanLocation(widget.from))
            : _withoutScan,
        child: Text(AppLocalizations.of(context).newEntry),
      ),
    );
  }
}
