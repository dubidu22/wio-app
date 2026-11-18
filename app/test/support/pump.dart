import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/app.dart';
import 'package:wio_app/auth/session_provider.dart';
import 'package:wio_app/auth/token_store.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/l10n/app_localizations.dart';
import 'package:wio_app/shell/providers.dart';
import 'package:wio_app/sync/sync_runner.dart';
import 'package:wio_app/update/app_version.dart';

import 'fake_api.dart';
import 'test_data.dart';

/// Phone size used by goldens and screenshots in PRs (CLAUDE.md: 390 x 844).
const Size phoneSize = Size(390, 844);

/// Pumps [screen] inside the app's theme and German localisation at phone size.
Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = phoneSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: wioLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: wioTheme(),
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}

/// The installed build the tests pretend to be (D-150).
const InstalledApp testInstalledApp = InstalledApp(
  version: '0.1.0+1',
  packageName: 'org.example.wio',
);

/// Tablet size of the second golden set (D-76).
const Size tabletSize = Size(820, 1180);

/// Pumps the whole app at [location] over [db], with a fixed clock and a
/// link opener that opens nothing (D-68). Signed in with the example session
/// unless [store] says otherwise; the API is [api] or a fake server that
/// answers with the example files, never the network. Sync does not start
/// by itself unless [autoSync] is set. Clears the tree at the end so
/// drift's stream timers finish inside the test.
Future<void> pumpWioApp(
  WidgetTester tester, {
  required WioDatabase db,
  String location = '/',
  Size size = phoneSize,
  double textScale = 1,
  DateTime? now,
  DateTime Function()? clock,
  LinkOpener? opener,
  TokenStore? store,
  FakeApi? api,
  String deviceName = 'Testtelefon',
  InstalledApp installed = testInstalledApp,
  bool autoSync = false,
  SyncTiming syncTiming = const SyncTiming(),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
  final fixedNow = now ?? testNow;
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock ?? () => fixedNow),
        linkOpenerProvider.overrideWithValue(opener ?? (uri) async => false),
        tokenStoreProvider.overrideWithValue(
          store ?? FakeTokenStore(exampleSession()),
        ),
        apiBaseUrlProvider.overrideWithValue(fakeApiBase),
        httpClientProvider.overrideWithValue((api ?? FakeApi()).client),
        deviceNameProvider.overrideWithValue(() async => deviceName),
        installedAppProvider.overrideWith((ref) async => installed),
        syncAutoStartProvider.overrideWithValue(autoSync),
        syncTimingProvider.overrideWithValue(syncTiming),
      ],
      child: WioApp(initialLocation: location),
    ),
  );
  await tester.pumpAndSettle();
}
