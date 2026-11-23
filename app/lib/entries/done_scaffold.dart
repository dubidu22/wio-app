import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../shell/back_button.dart';

/// The frame of the small entry screens that save (plan 104, as the title
/// screen of plan 103): **Fertig** top left saves and goes on, the system
/// back saves too ([onLeave], fire and forget).
class DoneScaffold extends StatelessWidget {
  const DoneScaffold({
    required this.title,
    required this.onDone,
    required this.onLeave,
    required this.body,
    super.key,
  });

  final String title;
  final Future<void> Function() onDone;
  final Future<void> Function() onLeave;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) unawaited(onLeave());
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: WioBackButton(
            label: l10n.entryDone,
            onPressed: () => unawaited(onDone()),
          ),
          leadingWidth: wioBackButtonWidth(context),
          title: Text(title),
        ),
        body: body,
      ),
    );
  }
}
