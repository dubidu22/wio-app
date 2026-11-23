@Tags(<String>['golden'])
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/app.dart';
import 'package:wio_app/data/entry_writer.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/l10n/app_localizations.dart';
import 'package:wio_app/planning/place_history.dart';
import 'package:wio_app/shell/providers.dart';

import '../support/pump.dart';
import '../support/test_data.dart';

/// Goldens are rendered on Linux only, where CI renders them (plan 002).
final bool _notLinux = !Platform.isLinux;

/// The section Verlauf of the entry screen (plan 108) on its own, until the
/// entry screen (#103) places it; run with `TZ=UTC` like the other goldens.
void main() {
  setUpAll(() {
    if (!_notLinux && DateTime.now().timeZoneOffset != Duration.zero) {
      fail('Run goldens with TZ=UTC (TZ=UTC flutter test --tags golden).');
    }
  });

  const sizes = <String, Size>{'phone': phoneSize, 'tablet': tabletSize};
  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    for (final empty in <bool>[false, true]) {
      final name = empty ? 'place_history_empty' : 'place_history';
      testWidgets('$name at $sizeName size', skip: _notLinux, (tester) async {
        final db = memoryDatabase();
        addTearDown(db.close);
        await seedWithHistory(db);
        if (!empty) {
          // One move the server has not answered yet.
          await EntryWriter(db, LocalWriter(db)).move(
            TestIds.kiste,
            const Place.room(
              siteId: TestIds.neueWohnung,
              roomId: TestIds.wohnzimmer,
            ),
          );
        }
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          ProviderScope(
            overrides: <Override>[
              databaseProvider.overrideWithValue(db),
              clockProvider.overrideWithValue(() => testNow),
            ],
            child: MaterialApp(
              locale: const Locale('de'),
              localizationsDelegates: wioLocalizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: wioTheme(),
              home: Scaffold(
                appBar: AppBar(title: const Text('Eintrag')),
                body: ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    PlaceHistorySection(
                      customerId: TestIds.familieBeispiel,
                      entryId: empty ? TestIds.kisteOhneOrt : TestIds.kiste,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(WidgetsApp),
          matchesGoldenFile('goldens/${name}_$sizeName.png'),
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 10));
      });
    }
  }
}
