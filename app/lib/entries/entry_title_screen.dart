import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/entry_writer.dart';
import '../l10n/app_localizations.dart';
import '../planning/place_screen.dart' show entryLocation;
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';

/// The entry's title (plan 103): one optional field, no hint that it is
/// required (UX rule 4). **Fertig**, back and leaving the app save it; an
/// empty field clears the title. Part of the entry task, not a level.
class EntryTitleScreen extends ConsumerStatefulWidget {
  const EntryTitleScreen({
    required this.customerId,
    required this.entryId,
    super.key,
  });

  final String customerId;
  final String entryId;

  @override
  ConsumerState<EntryTitleScreen> createState() => _EntryTitleScreenState();
}

class _EntryTitleScreenState extends ConsumerState<EntryTitleScreen> {
  final TextEditingController _field = TextEditingController();
  late final EntryWriter _writer;
  late final AppLifecycleListener _lifecycle;
  late ScaffoldMessengerState _messenger;
  late AppLocalizations _l10n;

  /// The field takes the entry's title once, so later sync changes do not
  /// overwrite what is being typed.
  bool _filled = false;

  /// The title as it was when the field was filled; saving it again would
  /// queue a change for nothing.
  String _saved = '';

  /// Saves run one after another.
  Future<void> _saves = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _writer = ref.read(entryWriterProvider);
    _lifecycle = AppLifecycleListener(
      onPause: () => unawaited(_save()),
      onHide: () => unawaited(_save()),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.of(context);
    _l10n = AppLocalizations.of(context);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _field.dispose();
    super.dispose();
  }

  Future<void> _save() {
    if (!_filled) return _saves;
    final value = _field.text.trim();
    return _saves = _saves.then((_) => _saveNow(value));
  }

  Future<void> _saveNow(String value) async {
    if (value == _saved) return;
    try {
      await _writer.editEntry(
        widget.entryId,
        title: Value<String?>(value.isEmpty ? null : value),
      );
      _saved = value;
    } on Object catch (error) {
      debugPrint('wio entry: title not saved: $error');
      _messenger.showSnackBar(
        SnackBar(content: Text(_l10n.entryTitleNotSaved)),
      );
    }
  }

  Future<void> _done() async {
    await _save();
    if (mounted) {
      context.go(entryLocation(widget.customerId, widget.entryId));
    }
  }

  void _fill(Entry entry) {
    if (_filled) return;
    _filled = true;
    _saved = entry.title?.trim() ?? '';
    _field.text = _saved;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entry = ref.watch(entryProvider(widget.entryId));
    final Entry? value = entry.value;
    if (value != null) _fill(value);
    final Widget body;
    if (value != null) {
      body = ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: <Widget>[
            TextField(
              controller: _field,
              textCapitalization: TextCapitalization.sentences,
              maxLength: EntryWriter.maxTitleLength,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: l10n.entryTitleField,
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
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) unawaited(_save());
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: WioBackButton(label: l10n.entryDone, onPressed: _done),
          leadingWidth: wioBackButtonWidth(context),
          title: Text(l10n.entryChangeTitle),
        ),
        body: body,
      ),
    );
  }
}
