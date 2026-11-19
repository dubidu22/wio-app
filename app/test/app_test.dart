import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/media/media_store.dart';

import 'support/fake_api.dart';
import 'support/pump.dart';
import 'support/test_data.dart';

void main() {
  testWidgets('the app starts in German on Aufträge with an empty database', (
    tester,
  ) async {
    final db = memoryDatabase();
    addTearDown(db.close);
    await pumpWioApp(tester, db: db);

    expect(find.text('Aufträge'), findsOneWidget);
    expect(find.text('Heute keine Aufträge.'), findsOneWidget);
    expect(find.text('Keine kommenden Aufträge.'), findsOneWidget);
  });

  testWidgets('an unknown address shows the job list', (tester) async {
    final db = memoryDatabase();
    addTearDown(db.close);
    await pumpWioApp(tester, db: db, location: '/no/such/page');

    expect(find.text('Aufträge'), findsOneWidget);
  });

  testWidgets('the first sync of a start waits for the media sweep (T4, '
      'D-421)', (tester) async {
    final db = memoryDatabase();
    addTearDown(db.close);
    await tester.runAsync(
      () => db
          .into(db.pictures)
          .insert(
            PicturesCompanion.insert(
              id: 'p1',
              workspaceId: TestIds.workspace,
              fileSha256: 'a' * 64,
              fileBytes: 10,
              fileMime: 'image/jpeg',
              widthPx: 1,
              heightPx: 1,
            ),
          ),
    );
    final store = _HeldSweepStore();
    final api = FakeApi();
    await pumpWioApp(
      tester,
      db: db,
      api: api,
      autoSync: true,
      mediaStore: store,
    );
    await settle(tester);
    expect(store.named, contains('a' * 64));
    expect(api.to('/auth/me'), hasLength(1));
    expect(api.to('/sync/pull'), isEmpty, reason: 'the sweep still runs');

    store.done.complete();
    await settle(tester);
    expect(api.to('/sync/pull'), isNotEmpty);
  });
}

/// A media store whose sweep finishes only when the test says so.
class _HeldSweepStore extends MediaStore {
  _HeldSweepStore() : super(() => Future<String>.error('no files'));

  final Completer<void> done = Completer<void>();
  Set<String>? named;

  @override
  Future<void> sweep(Set<String> keep, {required DateTime before}) {
    named = keep;
    return done.future;
  }
}
