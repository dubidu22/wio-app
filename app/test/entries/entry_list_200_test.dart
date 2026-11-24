// 200 entries on the customer screen, the demo workspace's customer (plan
// 105): rows build lazily and the list scrolls to its end.
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/entries/entry_list.dart';

import '../support/demo_workspace.dart';
import '../support/fake_api.dart';
import '../support/media.dart';
import '../support/pump.dart';
import '../support/test_data.dart';

void main() {
  testWidgets('200 entries build lazily and scroll to the end', (tester) async {
    // The demo workspace's customer has five live entries; 195 more.
    const customer = '01990000-0000-7000-8000-000300000001';
    final demo = memoryDatabase();
    addTearDown(demo.close);
    await tester.runAsync(() async {
      await DemoWorkspace.fromFile().load(demo);
      await demo.batch((b) {
        b.insertAll(demo.entries, <EntriesCompanion>[
          for (var i = 0; i < 195; i++)
            EntriesCompanion.insert(
              id: '01990000-0000-7000-8000-${(0xb00000000000 + i).toRadixString(16)}',
              workspaceId: '01990000-0000-7000-8000-000100000001',
              customerId: const Value<String?>(customer),
              title: Value<String?>(i == 0 ? 'Kiste Letzte' : 'Kiste $i'),
              siteId: const Value<String?>(
                '01990000-0000-7000-8000-000400000001',
              ),
              roomId: const Value<String?>(
                '01990000-0000-7000-8000-000500000001',
              ),
              // Kiste Letzte is the oldest; the rest are newer than the demo.
              createdAt: Value<String?>(
                i == 0
                    ? '2020-01-01T08:00:00.000Z'
                    : '2026-11-03T08:${(i ~/ 60).toString().padLeft(2, '0')}:${(i % 60).toString().padLeft(2, '0')}.000Z',
              ),
              revision: const Value<int?>(1),
            ),
        ]);
      });
    });
    await pumpWioApp(
      tester,
      db: demo,
      location: '/customers/$customer',
      store: FakeTokenStore(),
      mediaFolder: demoMediaFolder(),
    );

    // Only what is on screen (and a little more) is built.
    final built = find.byType(EntryRow).evaluate().length;
    expect(built, greaterThan(0));
    expect(built, lessThan(40));
    expect(find.text('Kiste Letzte'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Kiste Letzte'),
      // Small steps: other sections follow the list, so the end of the
      // scroll no longer leaves the last row on screen.
      300,
      maxScrolls: 200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Kiste Letzte'), findsOneWidget);
    final box = tester.renderObject<RenderBox>(
      find.ancestor(
        of: find.text('Kiste Letzte'),
        matching: find.byType(EntryRow),
      ),
    );
    expect(box.size.height, greaterThanOrEqualTo(72));
  });
}
