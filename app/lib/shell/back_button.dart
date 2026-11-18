import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';

/// Width of the app bar's leading slot that holds [WioBackButton].
const double wioBackButtonWidth = 136;

/// Back, top left, with the word "Zurück" next to the arrow (D-74, UX rules
/// 1 and 2). Goes to the job list when there is nothing to go back to, for
/// example after opening a link on the web.
class WioBackButton extends StatelessWidget {
  const WioBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          icon: const Icon(Icons.arrow_back),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(AppLocalizations.of(context).back),
          ),
        ),
      ),
    );
  }
}
