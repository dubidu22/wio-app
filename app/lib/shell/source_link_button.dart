import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import 'providers.dart';

/// The visible "Quellcode" button (AGPL-3.0 section 13, D-29, D-73). Opens
/// the source code in the browser; if no browser opens, shows the address.
class SourceLinkButton extends ConsumerWidget {
  const SourceLinkButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return TextButton(
      onPressed: () async {
        final uri = ref.read(sourceUrlProvider);
        final opened = await ref.read(linkOpenerProvider)(uri);
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.sourceLinkFallback(uri.toString()))),
          );
        }
      },
      child: Text(l10n.sourceLink),
    );
  }
}
