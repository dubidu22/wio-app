import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'app_too_old.dart';
import 'app_version.dart';
import 'store_link.dart';

/// Path of the update notice (D-154).
const String updateLocation = '/aktualisieren';

/// "Bitte die App aktualisieren" (D-154): opened once when the server says
/// the app is too old. It is not a gate (D-130): "Zurück" returns to the job
/// list, local work goes on, and nothing is deleted (D-156).
class UpdateRequiredScreen extends ConsumerStatefulWidget {
  const UpdateRequiredScreen({super.key});

  @override
  ConsumerState<UpdateRequiredScreen> createState() =>
      _UpdateRequiredScreenState();
}

class _UpdateRequiredScreenState extends ConsumerState<UpdateRequiredScreen> {
  /// The address nothing could open, shown to type in elsewhere.
  Uri? _unopened;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final minimum = ref.watch(appTooOldProvider)?.minimumVersion;
    final installed = ref.watch(installedAppProvider).value?.version;
    final target = ref.watch(updateTargetProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const WioBackButton(),
        leadingWidth: wioBackButtonWidth(context),
        title: Text(l10n.updateBarTitle),
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                l10n.updateTitle,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.updateText, style: theme.textTheme.titleMedium),
            if (minimum != null) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                l10n.updateMinimum(minimum),
                style: theme.textTheme.bodyLarge,
              ),
            ],
            if (installed != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                l10n.updateInstalled(installed),
                style: theme.textTheme.bodyLarge,
              ),
            ],
            if (target case OpenStore(:final searchHint?)) ...<Widget>[
              const SizedBox(height: 16),
              Text(switch (searchHint) {
                SearchHint.play => l10n.updateSearchPlay,
                SearchHint.appStore => l10n.updateSearchAppStore,
              }, style: theme.textTheme.bodyLarge),
            ],
            if (_unopened case final uri?) ...<Widget>[
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: SelectableText(
                  l10n.updateLinkFallback(uri.toString()),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ],
        ),
      ),
      // One main button at the bottom, within thumb reach (UX rule 3).
      bottomNavigationBar: SafeArea(
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: wioMaxContentWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: UpdateButton(
                main: true,
                onNotOpened: (uri) => setState(() => _unopened = uri),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "App aktualisieren" (D-153): opens the store page or reloads the web
/// app. When nothing opens, [onNotOpened] gets the address.
class UpdateButton extends ConsumerWidget {
  const UpdateButton({super.key, required this.onNotOpened, this.main = false});

  final void Function(Uri uri) onNotOpened;

  /// The notice's tall main button; the job-list hint uses the normal size.
  final bool main;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return FilledButton(
      style: main
          ? FilledButton.styleFrom(minimumSize: const Size.fromHeight(64))
          : null,
      onPressed: () async {
        switch (ref.read(updateTargetProvider)) {
          case ReloadPage():
            ref.read(pageReloaderProvider)();
          case OpenStore(:final uri):
            final opened = await ref.read(linkOpenerProvider)(uri);
            if (!opened && context.mounted) onNotOpened(uri);
        }
      },
      child: Text(l10n.updateButton),
    );
  }
}
