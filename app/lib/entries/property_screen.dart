import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../data/entry_queries.dart' show KeyChoice, PropertyOn;
import '../data/entry_writer.dart';
import '../l10n/app_localizations.dart';
import '../pictures/picture_screen.dart' show undoTime;
import '../planning/place_screen.dart' show entryLocation;
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';
import 'done_scaffold.dart';
import 'property_value.dart';

const TextInputType _numberPad = TextInputType.numberWithOptions(
  decimal: true,
  signed: true,
);

/// One property of an entry (plan 104): the value of a key used before
/// ([keyId]), or, without [keyId], **Neue Eigenschaft** with optional name,
/// unit and value. **Fertig** and back save; an empty value does nothing, a
/// value is removed by **Entfernen** with **Rückgängig** for 8 seconds (UX
/// rule 9). The number pad is used for a key with a unit or with only
/// numbers so far (D-429). Part of the entry task, not a level.
class PropertyScreen extends ConsumerStatefulWidget {
  const PropertyScreen({
    required this.customerId,
    required this.entryId,
    this.keyId,
    super.key,
  });

  final String customerId;
  final String entryId;
  final String? keyId;

  @override
  ConsumerState<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends ConsumerState<PropertyScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _unit = TextEditingController();
  final TextEditingController _value = TextEditingController();
  late final EntryWriter _writer;
  late ScaffoldMessengerState _messenger;
  late AppLocalizations _l10n;

  /// What the last build knew; the save may run after the screen is gone.
  String? _workspaceId;
  List<KeyChoice> _keys = const <KeyChoice>[];

  /// The value field takes the current value once.
  bool _filled = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _writer = ref.read(entryWriterProvider);
    _unit.addListener(() => setState(() {}));
    _name.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.of(context);
    _l10n = AppLocalizations.of(context);
  }

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    _value.dispose();
    super.dispose();
  }

  KeyChoice? _choice(String id) {
    for (final choice in _keys) {
      if (choice.key.id == id) return choice;
    }
    return null;
  }

  /// Saves what was typed. False when a number was expected and the text
  /// is none: nothing is written and the screen says so.
  Future<bool> _save() async {
    if (_busy) return true;
    final knownKeyId = widget.keyId;
    final raw = _value.text.trim();
    final KeyChoice? choice;
    final bool numeric;
    final String name = _name.text.trim();
    final String unit = _unit.text.trim();
    if (knownKeyId != null) {
      choice = _choice(knownKeyId);
      if (choice == null) return true;
      numeric = choice.numeric;
    } else {
      if (name.isEmpty || _workspaceId == null) return true;
      final twin = _twin(name);
      choice = twin;
      numeric = twin?.numeric ?? unit.isNotEmpty;
    }
    String? number;
    if (raw.isNotEmpty &&
        !numeric &&
        (choice == null || choice.liveValues == 0)) {
      // No unit and no value yet: a number typed on the text keyboard is
      // stored as a number, so the key becomes numeric (D-429, "only
      // numbers so far"). Other text stays text.
      number = parseNumber(raw);
    } else if (raw.isNotEmpty && numeric) {
      number = parseNumber(raw);
      if (number == null) {
        setState(() => _error = _l10n.propertyNumberNeeded);
        return false;
      }
    }
    _busy = true;
    try {
      final keyId =
          knownKeyId ??
          await _writer.keyNamed(
            workspaceId: _workspaceId!,
            name: name,
            unit: unit.isEmpty ? null : unit,
          );
      if (raw.isNotEmpty) {
        await _writer.setProperty(
          (type: 'entry', id: widget.entryId),
          keyId,
          text: number == null ? raw : null,
          number: number,
        );
      }
      return true;
    } on Object catch (error) {
      debugPrint('wio entry: property not saved: $error');
      _messenger.showSnackBar(
        SnackBar(content: Text(_l10n.vocabularyNotSaved)),
      );
      return true;
    } finally {
      _busy = false;
    }
  }

  KeyChoice? _twin(String name) {
    final key = localNameKey(name);
    for (final choice in _keys) {
      if (localNameKey(choice.key.name) == key) return choice;
    }
    return null;
  }

  Future<void> _done() async {
    if (await _save() && mounted) {
      context.go(entryLocation(widget.customerId, widget.entryId));
    }
  }

  Future<void> _leave() async {
    await _save();
  }

  Future<void> _remove(PropertyOn on) async {
    if (_busy) return;
    _busy = true;
    final router = GoRouter.of(context);
    final messenger = _messenger;
    final l10n = _l10n;
    final writer = _writer;
    final linkId = on.value.id;
    try {
      await writer.removeProperty(linkId);
    } on Object catch (error) {
      debugPrint('wio entry: property not removed: $error');
      _busy = false;
      messenger.showSnackBar(SnackBar(content: Text(l10n.vocabularyNotSaved)));
      return;
    }
    router.go(entryLocation(widget.customerId, widget.entryId));
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.propertyRemoved),
        duration: undoTime,
        persist: false,
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => writer.restorePropertyValue(linkId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final keyId = widget.keyId;
    final entry = ref.watch(entryProvider(widget.entryId));
    final keys = ref.watch(keyChoicesProvider);
    final values = ref.watch(entryPropertiesProvider(widget.entryId));
    final Entry? found = entry.value;
    _workspaceId = found?.workspaceId ?? _workspaceId;
    _keys = keys.value ?? _keys;
    final KeyChoice? choice = keyId == null ? null : _choice(keyId);
    PropertyOn? current;
    for (final value in values.value ?? const <PropertyOn>[]) {
      if (value.key.id == keyId) current = value;
    }
    if (!_filled && choice != null && values.hasValue) {
      _filled = true;
      final existing = current;
      if (existing != null) {
        _value.text = existing.value.valueNumber != null
            ? existing.value.valueNumber!.replaceFirst('.', ',')
            : (existing.value.valueText ?? '');
      }
    }
    final Object? failure = entry.error ?? keys.error ?? values.error;
    final bool ready = found != null && keys.hasValue && values.hasValue;
    final bool gone =
        keys.hasValue && keyId != null && choice == null && found != null;
    if (failure != null) {
      return Scaffold(
        appBar: _plainBar(context, l10n, l10n.propertiesHeading),
        body: LoadFailed(message: l10n.loadFailed, error: failure),
      );
    }
    if (entry is AsyncData<Entry?> && found == null) {
      return Scaffold(
        appBar: _plainBar(context, l10n, l10n.propertiesHeading),
        body: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HintText(l10n.entryMissing),
          ),
        ),
      );
    }
    if (gone) {
      return Scaffold(
        appBar: _plainBar(context, l10n, l10n.propertiesHeading),
        body: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HintText(l10n.propertyMissing),
          ),
        ),
      );
    }
    if (!ready || (keyId != null && choice == null)) {
      return Scaffold(
        appBar: _plainBar(context, l10n, l10n.propertiesHeading),
        body: const SizedBox.shrink(),
      );
    }
    final bool numeric = choice != null
        ? choice.numeric
        : (_twin(_name.text.trim())?.numeric ?? _unit.text.trim().isNotEmpty);
    final String? unit = choice?.key.unit;
    return DoneScaffold(
      title: choice?.key.name ?? l10n.propertyNew,
      onDone: _done,
      onLeave: _leave,
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: <Widget>[
            if (choice == null) ...<Widget>[
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                maxLength: EntryWriter.maxNameLength,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: l10n.propertyKeyField,
                  counterText: '',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _unit,
                maxLength: EntryWriter.maxUnitLength,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: l10n.propertyUnitField,
                  counterText: '',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _value,
              keyboardType: numeric ? _numberPad : TextInputType.text,
              inputFormatters: numeric
                  ? <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]')),
                    ]
                  : null,
              maxLength: EntryWriter.maxValueTextLength,
              style: Theme.of(context).textTheme.bodyLarge,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: l10n.propertyValueField,
                suffixText: unit,
                errorText: _error,
                counterText: '',
                border: const OutlineInputBorder(),
              ),
            ),
            if (current != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(64),
                  ),
                  onPressed: () => _remove(current!),
                  child: Text(l10n.propertyRemove),
                ),
              ),
          ],
        ),
      ),
    );
  }

  AppBar _plainBar(BuildContext context, AppLocalizations l10n, String title) =>
      AppBar(
        automaticallyImplyLeading: false,
        leading: const WioBackButton(),
        leadingWidth: wioBackButtonWidth(context),
        title: Text(title),
      );
}
