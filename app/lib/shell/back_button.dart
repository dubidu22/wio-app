import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';

/// Width of the app bar's leading slot that holds [WioBackButton]: 136 at
/// normal text size, growing with the system text size up to 216 at twice
/// the size, so "Zurück" keeps its size and the title keeps room.
double wioBackButtonWidth(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
  return 136 + (scale - 1) * 80;
}

/// Size of the arrow; fixed, so it never shrinks with the label.
const double wioBackIconSize = 24;

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
          icon: const Icon(Icons.arrow_back, size: wioBackIconSize),
          // Only beyond twice the text size does the word shrink to fit.
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(AppLocalizations.of(context).back),
          ),
        ),
      ),
    );
  }
}
