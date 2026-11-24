import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../data/queries.dart';
import '../l10n/app_localizations.dart';
import '../shell/providers.dart';
import 'record_scaffold.dart';

/// The small screen that adds or changes a job (plan 106): one date button
/// that opens a calendar (today preselected, no typing; UX rule 4) and the
/// main button **Anlegen** or **Ändern**; changing also offers **Löschen**
/// with **Rückgängig**.
class JobScreen extends ConsumerStatefulWidget {
  const JobScreen({required this.customerId, this.jobId, super.key});

  final String customerId;

  /// The job to change; null makes a new one.
  final String? jobId;

  @override
  ConsumerState<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends ConsumerState<JobScreen> {
  /// The chosen day; null until the clock or the job's date is read.
  DateTime? _date;

  /// How far ahead the calendar goes (plan 106, P6).
  static const int _yearsAhead = 2;

  bool get _changing => widget.jobId != null;

  String get _customerLocation => '/customers/${widget.customerId}';

  DateTime _today() {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _pick() async {
    final today = _today();
    final current = _date ?? today;
    final first = current.isBefore(today) ? current : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: first,
      lastDate: DateTime(today.year + _yearsAhead, today.month, today.day),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<String?> _save() async {
    final writer = ref.read(customerWriterProvider);
    final date = calendarDate(_date ?? _today());
    if (_changing) {
      await writer.changeJobDate(id: widget.jobId!, date: date);
    } else {
      await writer.createJob(customerId: widget.customerId, date: date);
    }
    return _customerLocation;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    var loaded = true;
    var missing = false;
    if (_changing) {
      final record = ref.watch(
        recordProvider((entity: 'jobs', id: widget.jobId!)),
      );
      loaded = record.hasValue;
      final value = record.value;
      missing = record.hasValue && value == null;
      final stored = value?.date;
      if (stored != null && _date == null) _date = DateTime.parse(stored);
    }
    final date = _date ?? _today();
    return RecordScaffold(
      title: _changing ? l10n.changeJobTitle : l10n.newJobTitle,
      entity: 'jobs',
      recordId: widget.jobId,
      loaded: loaded,
      missing: missing,
      onSave: _save,
      afterDelete: _customerLocation,
      deletedText: (l10n) => l10n.jobDeleted,
      form: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(64),
          alignment: Alignment.centerLeft,
        ),
        onPressed: _pick,
        child: Text(
          l10n.jobDateButton(date),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
