import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../auth/session_provider.dart';
import '../l10n/app_localizations.dart';
import '../pictures/picture_screen.dart' show undoTime;
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';

/// The shell of the screens that add, change or delete a customer, site,
/// room or job (plan 106): the back button, the owner check, the main
/// button at the bottom (**Anlegen** or **Ändern**) and **Löschen** with
/// **Rückgängig** for 8 seconds (UX rules 4 and 9). [form] is the field.
///
/// **Zurück** saves nothing: the main button is the only save.
class RecordScaffold extends ConsumerStatefulWidget {
  const RecordScaffold({
    required this.title,
    required this.entity,
    required this.recordId,
    required this.form,
    required this.onSave,
    required this.afterDelete,
    required this.deletedText,
    this.loaded = true,
    this.missing = false,
    super.key,
  });

  final String title;

  /// Table of the record being changed (`customers`, `sites`, `rooms`,
  /// `jobs`); with [recordId] null a new one is made.
  final String entity;
  final String? recordId;
  final Widget form;

  /// Saves; throws when it cannot. Returns where to go afterwards, or null
  /// to go back.
  final Future<String?> Function() onSave;

  /// Where to go after **Löschen**.
  final String afterDelete;
  final String Function(AppLocalizations) deletedText;

  /// False while the record of a change screen is still being read.
  final bool loaded;

  /// True when the record to change is gone.
  final bool missing;

  @override
  ConsumerState<RecordScaffold> createState() => _RecordScaffoldState();
}

class _RecordScaffoldState extends ConsumerState<RecordScaffold> {
  bool _busy = false;

  bool get _changing => widget.recordId != null;

  void _leave(String? location) {
    if (!mounted) return;
    if (location != null) {
      context.go(location);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      _leave(await widget.onSave());
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.recordNotSaved)));
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final writer = ref.read(customerWriterProvider);
    final entity = widget.entity;
    final id = widget.recordId!;
    try {
      await writer.delete(entity: entity, id: id);
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.recordNotSaved)));
      if (mounted) setState(() => _busy = false);
      return;
    }
    router.go(widget.afterDelete);
    messenger.showSnackBar(
      SnackBar(
        content: Text(widget.deletedText(l10n)),
        // UX rule 9: the note goes by itself; an action would otherwise
        // keep it on screen.
        duration: undoTime,
        persist: false,
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => writer.restore(entity: entity, id: id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final owner = ref.watch(isOwnerProvider);
    final Widget body;
    var canSave = false;
    if (session.isLoading && !session.hasValue) {
      body = const SizedBox.shrink();
    } else if (!owner) {
      body = _hint(l10n.recordOwnerOnly);
    } else if (widget.missing) {
      body = _hint(l10n.recordMissing);
    } else if (!widget.loaded) {
      body = const SizedBox.shrink();
    } else {
      canSave = true;
      body = ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: <Widget>[
            widget.form,
            if (_changing)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(64),
                  ),
                  onPressed: _delete,
                  child: Text(l10n.recordDelete),
                ),
              ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const WioBackButton(),
        leadingWidth: wioBackButtonWidth(context),
        title: Text(widget.title),
      ),
      body: body,
      bottomNavigationBar: canSave
          ? SafeArea(
              child: Align(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: wioMaxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(64),
                      ),
                      onPressed: _busy ? null : _save,
                      child: Text(
                        _changing ? l10n.recordChange : l10n.recordCreate,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _hint(String text) => ContentWidth(
    child: Padding(padding: const EdgeInsets.all(16), child: HintText(text)),
  );
}
