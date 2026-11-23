// Labels and properties on the entry screen (plan 104, P1..P8).
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/entry_writer.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/entries/entry_screen.dart';
import 'package:wio_app/entries/label_new_screen.dart';
import 'package:wio_app/entries/property_screen.dart';
import 'package:wio_app/shell/providers.dart';

import '../support/pump.dart';
import '../support/test_data.dart';
import '../support/ux_guidelines.dart';

/// A writer whose removal of a property value fails.
class _FailingWriter extends EntryWriter {
  _FailingWriter(WioDatabase db) : super(db, LocalWriter(db));

  @override
  Future<void> removeProperty(String linkId) =>
      Future<void>.error(StateError('no'));
}

const String _kiste =
    '/customers/${TestIds.familieBeispiel}/entries/${TestIds.kiste}';

Finder _chip(String text) => find.ancestor(
  of: find.text(text),
  matching: find.byWidgetPredicate(
    (w) => w is OutlinedButton || w is FilledButton,
  ),
);

Finder _button(String text) =>
    find.ancestor(of: find.text(text), matching: find.byType(OutlinedButton));

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await seedWithVocabulary(db);
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, String location) =>
      pumpWioApp(tester, db: db, location: location);

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<List<EntityLabel>> liveLabelLinks(WidgetTester tester) async {
    final all = (await tester.runAsync(
      () => db.select(db.entityLabels).get(),
    ))!;
    return [
      for (final l in all)
        if (l.entityId == TestIds.kiste && l.deletedAt == null) l,
    ];
  }

  Future<List<EntityProperty>> values(WidgetTester tester) async {
    final all = (await tester.runAsync(
      () => db.select(db.entityProperties).get(),
    ))!;
    return [
      for (final p in all)
        if (p.entityId == TestIds.kiste) p,
    ];
  }

  Future<int> labelCount(WidgetTester tester) async =>
      (await tester.runAsync(() => db.select(db.labels).get()))!.length;

  TextInputType? keyboard(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField).last).keyboardType;

  group('labels', () {
    testWidgets('chips of all labels, newest used first, state in words', (
      tester,
    ) async {
      await pump(tester, _kiste);
      await scrollTo(tester, find.text('Neues Label'));
      expect(find.text('Labels'), findsOneWidget);
      final glas = tester.getTopLeft(_chip('Glas'));
      final zerbrechlich = tester.getTopLeft(_chip('Zerbrechlich · gewählt'));
      final kueche = tester.getTopLeft(_chip('Küche'));
      // One wrap: reading order is Glas, Zerbrechlich, Küche.
      bool before(Offset a, Offset b) =>
          a.dy < b.dy || (a.dy == b.dy && a.dx < b.dx);
      expect(before(glas, zerbrechlich), isTrue);
      expect(before(zerbrechlich, kueche), isTrue);
      expect(_chip('Zerbrechlich · gewählt'), findsOneWidget);
      expect(find.text('Glas · gewählt'), findsNothing);
      // The section sits between the notes and the place (D-482).
      expect(
        tester.getTopLeft(find.text('Labels')).dy,
        lessThan(tester.getTopLeft(find.text('Eigenschaften')).dy),
      );
    });

    testWidgets('a tap adds the label, a tap on a chosen chip removes it', (
      tester,
    ) async {
      await pump(tester, _kiste);
      await scrollTo(tester, _chip('Glas'));
      await tester.tap(_chip('Glas'));
      await tester.pumpAndSettle();
      expect(find.text('Glas · gewählt'), findsOneWidget);
      expect(
        (await liveLabelLinks(tester)).map((l) => l.labelId),
        contains(TestIds.labelGlas),
      );

      await tester.tap(_chip('Glas · gewählt'));
      await tester.pumpAndSettle();
      expect(find.text('Glas'), findsOneWidget);
      expect((await liveLabelLinks(tester)).map((l) => l.labelId), [
        TestIds.labelZerbrechlich,
      ]);

      // Tapping again brings the same link back (D-442).
      await tester.tap(_chip('Glas'));
      await tester.pumpAndSettle();
      expect(find.text('Glas · gewählt'), findsOneWidget);
      final changes = (await tester.runAsync(
        () => db.select(db.outbox).get(),
      ))!;
      expect(
        changes.where((c) => c.entity == 'entity_labels').map((c) => c.op),
        <String>['upsert', 'delete', 'restore'],
      );
    });

    testWidgets('Neues Label reuses a label of the same name (D-51)', (
      tester,
    ) async {
      await pump(tester, _kiste);
      await scrollTo(tester, _button('Neues Label'));
      await tester.tap(_button('Neues Label'));
      await tester.pumpAndSettle();
      expect(find.byType(LabelNewScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField), '  KÜCHE ');
      await tester.tap(find.text('Fertig'));
      await tester.pumpAndSettle();

      expect(find.byType(EntryScreen), findsOneWidget);
      expect(await labelCount(tester), 3);
      expect(
        (await liveLabelLinks(tester)).map((l) => l.labelId),
        contains(TestIds.labelKueche),
      );
      await scrollTo(tester, find.text('Neues Label'));
      expect(find.text('Küche · gewählt'), findsOneWidget);
    });

    testWidgets('an empty field adds nothing', (tester) async {
      await pump(tester, '$_kiste/label');
      await tester.tap(find.text('Fertig'));
      await tester.pumpAndSettle();
      expect(find.byType(EntryScreen), findsOneWidget);
      expect(await labelCount(tester), 3);
      expect((await liveLabelLinks(tester)), hasLength(1));
    });

    testWidgets('a new word becomes a chip', (tester) async {
      await pump(tester, '$_kiste/label');
      await tester.enterText(find.byType(TextField), 'Keller');
      await tester.tap(find.text('Fertig'));
      await tester.pumpAndSettle();
      expect(await labelCount(tester), 4);
      await scrollTo(tester, find.text('Neues Label'));
      // The new label is pending, so it is the most recent: first chip.
      expect(find.text('Keller · gewählt'), findsOneWidget);
      expect(
        tester.getTopLeft(_chip('Keller · gewählt')).dx,
        lessThan(tester.getTopLeft(_chip('Glas')).dx),
      );
    });

    testWidgets('the screens meet the UX rules', (tester) async {
      await pump(tester, _kiste);
      await scrollTo(tester, find.text('Neues Label'));
      await expectMeetsUxRules(tester);
    });
  });

  group('properties', () {
    testWidgets('chips of the keys, the value in words', (tester) async {
      await pump(tester, _kiste);
      await scrollTo(tester, find.text('Neue Eigenschaft'));
      expect(find.text('Eigenschaften'), findsOneWidget);
      expect(_chip('Gewicht: 12 kg'), findsOneWidget);
      expect(_chip('Material'), findsOneWidget);
      expect(_chip('Farbe'), findsOneWidget);
      expect(
        tester.getTopLeft(_chip('Material')).dx,
        lessThan(tester.getTopLeft(_chip('Gewicht: 12 kg')).dx),
      );
    });

    testWidgets('a key with a unit gets the number pad; a comma is saved '
        'as a dot and the one value is changed', (tester) async {
      await pump(tester, _kiste);
      await scrollTo(tester, _chip('Gewicht: 12 kg'));
      await tester.tap(_chip('Gewicht: 12 kg'));
      await tester.pumpAndSettle();
      expect(find.byType(PropertyScreen), findsOneWidget);
      expect(find.text('Gewicht'), findsWidgets);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
      expect(
        keyboard(tester),
        const TextInputType.numberWithOptions(decimal: true, signed: true),
      );
      await tester.enterText(find.byType(TextField), '2,5');
      await tester.tap(find.text('Fertig'));
      await tester.pumpAndSettle();

      expect(find.byType(EntryScreen), findsOneWidget);
      final all = await values(tester);
      expect(all, hasLength(1));
      expect(all.single.valueNumber, '2.5');
      expect(all.single.valueText, isNull);
      await scrollTo(tester, find.text('Neue Eigenschaft'));
      expect(_chip('Gewicht: 2,5 kg'), findsOneWidget);
    });

    testWidgets('text that is no number is not saved and says so', (
      tester,
    ) async {
      await pump(tester, '$_kiste/eigenschaft/${TestIds.keyGewicht}');
      await tester.enterText(find.byType(TextField), '1.2.3');
      await tester.tap(find.text('Fertig'));
      await tester.pumpAndSettle();
      expect(find.byType(PropertyScreen), findsOneWidget);
      expect(find.text('Bitte eine Zahl eingeben.'), findsOneWidget);
      expect((await values(tester)).single.valueNumber, '12');
    });

    testWidgets(
      'a key without values and without unit gets the text keyboard',
      (tester) async {
        await pump(tester, '$_kiste/eigenschaft/${TestIds.keyFarbe}');
        expect(keyboard(tester), TextInputType.text);
        await tester.enterText(find.byType(TextField), 'Rot');
        await tester.tap(find.text('Fertig'));
        await tester.pumpAndSettle();
        final red = (await values(tester))
            .where((p) => p.keyId == TestIds.keyFarbe);
        expect(red.single.valueText, 'Rot');
        expect(red.single.valueNumber, isNull);
        // No value on the entry yet, so no Entfernen.
      },
    );

    testWidgets('a key with text values gets the text keyboard', (
      tester,
    ) async {
      await pump(tester, '$_kiste/eigenschaft/${TestIds.keyMaterial}');
      expect(keyboard(tester), TextInputType.text);
      expect(find.text('Entfernen'), findsNothing);
    });

    testWidgets('an empty value does nothing', (tester) async {
      await pump(tester, '$_kiste/eigenschaft/${TestIds.keyFarbe}');
      await tester.tap(find.text('Fertig'));
      await tester.pumpAndSettle();
      expect(find.byType(EntryScreen), findsOneWidget);
      expect(
        (await values(tester)).where((p) => p.keyId == TestIds.keyFarbe),
        isEmpty,
      );
    });

    testWidgets('Entfernen removes with Rückgängig', (tester) async {
      await pump(tester, '$_kiste/eigenschaft/${TestIds.keyGewicht}');
      await tester.tap(_button('Entfernen'));
      await tester.pumpAndSettle();
      expect(find.byType(EntryScreen), findsOneWidget);
      expect(find.text('Eigenschaft entfernt.'), findsOneWidget);
      expect((await values(tester)).single.deletedAt, isNotNull);

      await tester.tap(find.text('Rückgängig'));
      await tester.pumpAndSettle();
      expect((await values(tester)).single.deletedAt, isNull);
    });

    testWidgets('Neue Eigenschaft creates the key with unit and value', (
      tester,
    ) async {
      await pump(tester, '$_kiste/eigenschaft/neu');
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(3));
      await tester.enterText(fields.at(0), 'Höhe');
      await tester.enterText(fields.at(1), 'cm');
      await tester.pumpAndSettle();
      expect(
        keyboard(tester),
        const TextInputType.numberWithOptions(decimal: true, signed: true),
      );
      await tester.enterText(fields.at(2), '40');
      await tester.tap(find.text('Fertig'));
      await tester.pumpAndSettle();

      final keys = (await tester.runAsync(
        () => db.select(db.propertyKeys).get(),
      ))!;
      expect(keys, hasLength(4));
      final height = keys.firstWhere((k) => k.name == 'Höhe');
      expect(height.unit, 'cm');
      final value = (await values(tester))
          .firstWhere((p) => p.keyId == height.id);
      expect(value.valueNumber, '40');
      await scrollTo(tester, find.text('Neue Eigenschaft'));
      expect(_chip('Höhe: 40 cm'), findsOneWidget);
    });

    testWidgets('a new name equal to a key reuses it and its unit (D-51)', (
      tester,
    ) async {
      await pump(tester, '$_kiste/eigenschaft/neu');
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'GEWICHT');
      await tester.enterText(fields.at(2), '3,5');
      await tester.tap(find.text('Fertig'));
      await tester.pumpAndSettle();
      expect(
        (await tester.runAsync(() => db.select(db.propertyKeys).get()))!,
        hasLength(3),
      );
      expect((await values(tester)).single.valueNumber, '3.5');
    });

    testWidgets('a key that is gone shows a hint', (tester) async {
      await pump(tester, '$_kiste/eigenschaft/no-such-key');
      expect(
        find.text('Diese Eigenschaft gibt es nicht mehr.'),
        findsOneWidget,
      );
    });

    testWidgets('the value screen meets the UX rules', (tester) async {
      await pump(tester, '$_kiste/eigenschaft/${TestIds.keyGewicht}');
      expect(find.byType(PropertyScreen), findsOneWidget);
      await expectMeetsUxRules(tester);
    });

    testWidgets('the new property screen meets the UX rules', (tester) async {
      await pump(tester, '$_kiste/eigenschaft/neu');
      expect(find.byType(PropertyScreen), findsOneWidget);
      await expectMeetsUxRules(tester);
    });

    testWidgets('a number typed for a key without values makes it numeric', (
      tester,
    ) async {
      await pump(tester, '$_kiste/eigenschaft/neu');
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Anzahl');
      await tester.enterText(fields.at(2), '3');
      await tester.tap(find.text('Fertig'));
      await tester.pumpAndSettle();
      final all = await values(tester);
      final anzahl = (await tester.runAsync(
        () => db.select(db.propertyKeys).get(),
      ))!.firstWhere((k) => k.name == 'Anzahl');
      final value = all.firstWhere((p) => p.keyId == anzahl.id);
      expect(value.valueNumber, '3');
      expect(value.valueText, isNull);
    });

    testWidgets('such a key opens with the number pad next time', (
      tester,
    ) async {
      await pump(tester, '$_kiste/eigenschaft/${TestIds.keyFarbe}');
      await tester.enterText(find.byType(TextField), '7');
      await tester.tap(find.text('Fertig'));
      await tester.pumpAndSettle();
      await scrollTo(tester, _chip('Farbe: 7'));
      await tester.tap(_chip('Farbe: 7'));
      await tester.pumpAndSettle();
      expect(
        keyboard(tester),
        const TextInputType.numberWithOptions(decimal: true, signed: true),
      );
    });

    testWidgets('text for a key without values stays text', (tester) async {
      await pump(tester, '$_kiste/eigenschaft/${TestIds.keyFarbe}');
      await tester.enterText(find.byType(TextField), 'Rot 3');
      await tester.tap(find.text('Fertig'));
      await tester.pumpAndSettle();
      final red = (await values(tester))
          .firstWhere((p) => p.keyId == TestIds.keyFarbe);
      expect(red.valueText, 'Rot 3');
      expect(red.valueNumber, isNull);
    });

    testWidgets('typing the name of a number key switches the keyboard', (
      tester,
    ) async {
      await pump(tester, '$_kiste/eigenschaft/neu');
      final fields = find.byType(TextField);
      expect(keyboard(tester), TextInputType.text);
      await tester.enterText(fields.at(0), 'gewicht');
      await tester.pumpAndSettle();
      expect(
        keyboard(tester),
        const TextInputType.numberWithOptions(decimal: true, signed: true),
      );
    });

    testWidgets('a failed Entfernen says so and stays', (tester) async {
      await pumpWioApp(
        tester,
        db: db,
        location: '$_kiste/eigenschaft/${TestIds.keyGewicht}',
        overrides: <Override>[
          entryWriterProvider.overrideWithValue(_FailingWriter(db)),
        ],
      );
      await tester.tap(_button('Entfernen'));
      await tester.pumpAndSettle();
      expect(find.text('Nicht gespeichert.'), findsOneWidget);
      expect(find.byType(PropertyScreen), findsOneWidget);
      expect((await values(tester)).single.deletedAt, isNull);
    });
  });
}
