// The place choices follow the database after another screen was open on
// top of the one that watches them (issue 115, plan 115).
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/entries/entry_screen.dart';
import 'package:wio_app/planning/place_choices.dart';
import 'package:wio_app/planning/place_providers.dart';
import 'package:wio_app/shell/providers.dart';

import '../support/media.dart';
import '../support/pump.dart';
import '../support/test_data.dart';

class _Watcher extends ConsumerWidget {
  const _Watcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choices = ref.watch(
      placeChoicesProvider((
        customerId: TestIds.familieBeispiel,
        entryId: TestIds.kiste,
      )),
    );
    final PlaceChoices? found = choices.value;
    final names = <String>[
      if (found != null)
        for (final site in found.sites)
          for (final room in site.rooms) room.name ?? '-',
    ];
    return Scaffold(
      body: Column(
        children: <Widget>[
          Text('rooms: ${names.join(',')}'),
          Text('title: ${found?.entry.title}'),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(body: const Text('on top')),
              ),
            ),
            child: const Text('open'),
          ),
        ],
      ),
    );
  }
}

const String _kiste =
    '/customers/${TestIds.familieBeispiel}/entries/${TestIds.kiste}';

void main() {
  late WioDatabase db;
  setUp(() async {
    db = memoryDatabase();
    await seedWithEntryContent(db);
  });
  tearDown(() async => db.close());

  testWidgets('a change made while another screen covers it shows on return', (
    tester,
  ) async {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 10));
    });
    await pumpScreen(
      tester,
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const _Watcher(),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await db.update(db.rooms).write(const RoomsCompanion(name: Value('Neu')));
    await db
        .update(db.entries)
        .write(const EntriesCompanion(title: Value('Neuer Titel')));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('on top'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('title: Neuer Titel'), findsOneWidget);
    expect(find.text('rooms: Neu,Neu,Neu'), findsOneWidget);
  });

  testWidgets('after the picker returns to the entry screen, the choices '
      'hold the new place', (tester) async {
    await pumpWioApp(
      tester,
      db: db,
      location: _kiste,
      mediaFolder: demoMediaFolder(),
    );
    Finder button(String text) => find.ancestor(
      of: find.text(text),
      matching: find.byType(OutlinedButton),
    );
    final key = (customerId: TestIds.familieBeispiel, entryId: TestIds.kiste);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(EntryScreen)),
    );
    await tester.pumpAndSettle();
    expect(container.read(placeChoicesProvider(key)).value, isNotNull);
    await tester.drag(find.byType(ListView).first, const Offset(0, -1500));
    await tester.pumpAndSettle();
    await tester.tap(button('Ort ändern'));
    await tester.pumpAndSettle();
    await tester.tap(button('Wohnzimmer'));
    await tester.pumpAndSettle();
    await tester.tap(button('Boden'));
    await tester.pumpAndSettle();
    expect(find.byType(EntryScreen), findsOneWidget);
    expect(
      container.read(placeChoicesProvider(key)).value?.entry.roomId,
      TestIds.wohnzimmer,
    );
  });
}
