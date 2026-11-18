import 'package:flutter_test/flutter_test.dart';

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
}
