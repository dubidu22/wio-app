// "Most recently used first" and the keyboard counts (plan 104, P3, P6).
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/entry_queries.dart';
import 'package:wio_app/data/entry_writer.dart';
import 'package:wio_app/data/local_writer.dart';

import '../support/test_data.dart';

void main() {
  late WioDatabase db;
  late EntryWriter writer;

  setUp(() async {
    db = memoryDatabase();
    writer = EntryWriter(db, LocalWriter(db));
    await seedWithVocabulary(db);
  });
  tearDown(() => db.close());

  Future<List<String>> labelNames() async => [
    for (final label in await watchLabelChoices(db).first) label.name,
  ];

  test('labels: newest link first, never used last', () async {
    expect(await labelNames(), <String>['Glas', 'Zerbrechlich', 'Küche']);
  });

  test('a link the server has not confirmed is the newest of all', () async {
    await writer.addLabel((
      type: 'entry',
      id: TestIds.kiste,
    ), TestIds.labelKueche);
    expect(await labelNames(), <String>['Küche', 'Glas', 'Zerbrechlich']);
  });

  test('a removed link still counts as use', () async {
    final links = await watchLabelsOf(db, (
      type: 'entry',
      id: TestIds.kisteOhneOrt,
    )).first;
    await writer.removeLabel(links.single.linkId);
    expect(await labelNames(), <String>['Glas', 'Zerbrechlich', 'Küche']);
  });

  test('a deleted label is not offered', () async {
    await writer.deleteLabel(TestIds.labelGlas);
    expect(await labelNames(), <String>['Zerbrechlich', 'Küche']);
  });

  test('labels never used: newest first, then by name', () async {
    final a = await writer.labelNamed(
      workspaceId: TestIds.workspace,
      name: 'B',
    );
    final b = await writer.labelNamed(
      workspaceId: TestIds.workspace,
      name: 'A',
    );
    expect(a, isNot(b));
    // Both are pending (no created_at): the same stamp, so by name.
    expect(await labelNames(), <String>[
      'Glas',
      'Zerbrechlich',
      'A',
      'B',
      'Küche',
    ]);
  });

  test('keys: newest value first, counts decide the number pad', () async {
    final keys = await watchKeyChoices(db).first;
    expect(
      [for (final k in keys) k.key.name],
      <String>['Material', 'Gewicht', 'Farbe'],
    );
    final byName = {for (final k in keys) k.key.name: k};
    expect(byName['Material']!.liveValues, 1);
    expect(byName['Material']!.textValues, 1);
    expect(byName['Material']!.numeric, isFalse);
    expect(byName['Gewicht']!.numeric, isTrue); // unit
    expect(byName['Farbe']!.liveValues, 0);
    expect(byName['Farbe']!.numeric, isFalse); // no value, no unit
  });

  test(
    'a key with numbers only gets the number pad, a removed value not',
    () async {
      final keyId = await writer.keyNamed(
        workspaceId: TestIds.workspace,
        name: 'Höhe',
      );
      final subject = (type: 'entry', id: TestIds.kiste);
      final link = await writer.setProperty(subject, keyId, number: '40');
      KeyChoice find(List<KeyChoice> all) =>
          all.firstWhere((k) => k.key.id == keyId);
      var choice = find(await watchKeyChoices(db).first);
      expect(choice.numeric, isTrue);
      expect(choice.key.unit, isNull);

      await writer.setProperty(subject, keyId, text: 'hoch');
      choice = find(await watchKeyChoices(db).first);
      expect(choice.textValues, 1);
      expect(choice.numeric, isFalse);

      await writer.removeProperty(link);
      choice = find(await watchKeyChoices(db).first);
      expect(choice.liveValues, 0);
      expect(choice.numeric, isFalse);
    },
  );
}
