import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../auth/session_provider.dart';
import '../data/customer_writer.dart';
import '../data/queries.dart' show calendarDate;
import '../l10n/app_localizations.dart';
import '../shell/providers.dart';
import 'record_scaffold.dart';

/// What a [NameScreen] adds or changes (plan 106).
enum NameKind {
  customer('customers'),
  site('sites'),
  room('rooms');

  const NameKind(this.entity);

  /// The table of the record.
  final String entity;

  String title(AppLocalizations l10n, {required bool changing}) =>
      switch (this) {
        customer => changing ? l10n.changeCustomer : l10n.newCustomerTitle,
        site => changing ? l10n.changeSite : l10n.newSiteTitle,
        room => changing ? l10n.changeRoom : l10n.newRoomTitle,
      };

  String field(AppLocalizations l10n) => switch (this) {
    customer => l10n.customerNameField,
    site => l10n.siteNameField,
    room => l10n.roomNameField,
  };

  String deleted(AppLocalizations l10n) => switch (this) {
    customer => l10n.customerDeleted,
    site => l10n.siteDeleted,
    room => l10n.roomDeleted,
  };
}

/// The small screen that adds or changes a customer, a site or a room
/// (plan 106): one optional name field (the keyboard's microphone key
/// dictates it; UX rule 4) and the main button **Anlegen** or **Ändern**;
/// changing also offers **Löschen** with **Rückgängig**.
///
/// * a new customer: no ids;
/// * a new site: [customerId];
/// * a new room: [customerId] and [siteId];
/// * a change: [kind]'s [recordId] and [customerId] (null for a customer
///   itself).
class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({
    required this.kind,
    this.customerId,
    this.siteId,
    this.recordId,
    super.key,
  });

  final NameKind kind;
  final String? customerId;
  final String? siteId;
  final String? recordId;

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  final TextEditingController _field = TextEditingController();

  /// The field takes the record's name once, so later sync changes do not
  /// overwrite what is being typed.
  bool _filled = false;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  bool get _changing => widget.recordId != null;

  String get _customerLocation => '/customers/${widget.customerId}';

  Future<String?> _save() async {
    final writer = ref.read(customerWriterProvider);
    final name = _field.text;
    switch ((widget.kind, _changing)) {
      case (NameKind.customer, false):
        final session = ref.read(sessionProvider).value!;
        final date = calendarDate(ref.read(clockProvider)());
        final id = await writer.createCustomer(
          workspaceId: session.workspace.id,
          name: name,
          date: date,
        );
        return '/customers/$id';
      case (NameKind.site, false):
        await writer.createSite(customerId: widget.customerId!, name: name);
        return _customerLocation;
      case (NameKind.room, false):
        await writer.createRoom(siteId: widget.siteId!, name: name);
        return _customerLocation;
      case (_, true):
        await writer.rename(
          entity: widget.kind.entity,
          id: widget.recordId!,
          name: name,
        );
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kind = widget.kind;
    var loaded = true;
    var missing = false;
    if (_changing) {
      final record = ref.watch(
        recordProvider((entity: kind.entity, id: widget.recordId!)),
      );
      loaded = record.hasValue;
      final value = record.value;
      missing = record.hasValue && value == null;
      if (value != null && !_filled) {
        _filled = true;
        _field.text = value.name ?? '';
      }
    }
    return RecordScaffold(
      title: kind.title(l10n, changing: _changing),
      entity: kind.entity,
      recordId: widget.recordId,
      loaded: loaded,
      missing: missing,
      onSave: _save,
      afterDelete: kind == NameKind.customer ? '/' : _customerLocation,
      deletedText: kind.deleted,
      form: TextField(
        controller: _field,
        autofocus: !_changing,
        textCapitalization: TextCapitalization.words,
        maxLength: CustomerWriter.maxNameLength,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: kind.field(l10n),
          counterText: '',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
