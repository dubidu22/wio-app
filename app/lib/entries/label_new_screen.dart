import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/entry_writer.dart';
import '../l10n/app_localizations.dart';
import '../planning/place_screen.dart' show entryLocation;
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'done_scaffold.dart';

/// **Neues Label** (plan 104): one optional word, typed or dictated with the
/// keyboard's microphone key, asked once. **Fertig** and back put the label
/// on the entry; a label with the same name (D-51) is reused, an empty
/// field adds nothing (UX rule 4). Part of the entry task, not a level.
class LabelNewScreen extends ConsumerStatefulWidget {
  const LabelNewScreen({
    required this.customerId,
    required this.entryId,
    super.key,
  });

  final String customerId;
  final String entryId;

  @override
  ConsumerState<LabelNewScreen> createState() => _LabelNewScreenState();
}

class _LabelNewScreenState extends ConsumerState<LabelNewScreen> {
  final TextEditingController _field = TextEditingController();
  late final EntryWriter _writer;
  late ScaffoldMessengerState _messenger;
  late AppLocalizations _l10n;
  String? _workspaceId;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _writer = ref.read(entryWriterProvider);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.of(context);
    _l10n = AppLocalizations.of(context);
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  /// Puts the typed label on the entry once.
  Future<void> _save() async {
    final name = _field.text.trim();
    final workspaceId = _workspaceId;
    if (_saved || name.isEmpty || workspaceId == null) return;
    _saved = true;
    try {
      final id = await _writer.labelNamed(workspaceId: workspaceId, name: name);
      await _writer.addLabel((type: 'entry', id: widget.entryId), id);
    } on Object catch (error) {
      _saved = false;
      debugPrint('wio entry: label not saved: $error');
      _messenger.showSnackBar(
        SnackBar(content: Text(_l10n.vocabularyNotSaved)),
      );
    }
  }

  Future<void> _done() async {
    await _save();
    if (mounted) {
      context.go(entryLocation(widget.customerId, widget.entryId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entry = ref.watch(entryProvider(widget.entryId));
    final Entry? value = entry.value;
    _workspaceId = value?.workspaceId ?? _workspaceId;
    final Widget body;
    if (value != null) {
      body = ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: <Widget>[
            TextField(
              controller: _field,
              textCapitalization: TextCapitalization.sentences,
              maxLength: EntryWriter.maxNameLength,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: l10n.labelField,
                counterText: '',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      );
    } else if (entry is AsyncData<Entry?>) {
      body = ContentWidth(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: HintText(l10n.entryMissing),
        ),
      );
    } else if (entry is AsyncError<Entry?>) {
      body = LoadFailed(message: l10n.loadFailed, error: entry.error);
    } else {
      body = const SizedBox.shrink();
    }
    return DoneScaffold(
      title: l10n.labelNew,
      onDone: _done,
      onLeave: _save,
      body: body,
    );
  }
}
