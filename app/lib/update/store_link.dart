import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shell/providers.dart';
import 'app_version.dart';
import 'page_reload.dart'
    if (dart.library.js_interop) 'page_reload_web.dart'
    as platform;

/// The app's numeric App Store id, set in the release build with
/// `--dart-define=WIO_IOS_APP_STORE_ID=<id>` once the App Store record
/// exists (D-153). Empty until then.
const String wioIosAppStoreId = String.fromEnvironment('WIO_IOS_APP_STORE_ID');

/// What "App aktualisieren" does (D-153).
sealed class UpdateTarget {
  const UpdateTarget();
}

/// Where to search for the app when its store page is not known.
enum SearchHint { play, appStore }

/// Opens [uri]: the app's store page, or the store itself when the page is
/// not known; then [searchHint] says to search for the app there.
class OpenStore extends UpdateTarget {
  const OpenStore(this.uri, {this.searchHint});

  final Uri uri;
  final SearchHint? searchHint;
}

/// Loads the web app again, which fetches the new build.
class ReloadPage extends UpdateTarget {
  const ReloadPage();
}

/// The update target on [platform] (D-153): the Play page from the installed
/// [packageName] on Android, the App Store page from [iosAppStoreId] on iOS
/// (the App Store app with a search hint while the id is not set), a reload
/// on the web. Other platforms are not shipped; they open [sourceUrl], where
/// a new build can be had.
UpdateTarget updateTarget({
  required bool web,
  required TargetPlatform platform,
  required String packageName,
  required String iosAppStoreId,
  required Uri sourceUrl,
}) {
  if (web) return const ReloadPage();
  switch (platform) {
    case TargetPlatform.android:
      if (packageName.isEmpty) {
        return OpenStore(
          Uri.parse('https://play.google.com/store/apps'),
          searchHint: SearchHint.play,
        );
      }
      return OpenStore(
        Uri.https('play.google.com', '/store/apps/details', <String, String>{
          'id': packageName,
        }),
      );
    case TargetPlatform.iOS:
      if (RegExp(r'^[0-9]+$').hasMatch(iosAppStoreId)) {
        return OpenStore(Uri.https('apps.apple.com', '/app/id$iosAppStoreId'));
      }
      return OpenStore(
        Uri.parse('itms-apps://apps.apple.com/'),
        searchHint: SearchHint.appStore,
      );
    case TargetPlatform.fuchsia ||
        TargetPlatform.linux ||
        TargetPlatform.macOS ||
        TargetPlatform.windows:
      return OpenStore(sourceUrl);
  }
}

/// The App Store id of this build. Tests override it.
final iosAppStoreIdProvider = Provider<String>((ref) => wioIosAppStoreId);

/// Whether this is the web build. Tests override it.
final isWebProvider = Provider<bool>((ref) => kIsWeb);

/// The update target of this device; Android until the package name is read.
final updateTargetProvider = Provider<UpdateTarget>((ref) {
  final installed = ref.watch(installedAppProvider).value;
  return updateTarget(
    web: ref.watch(isWebProvider),
    platform: defaultTargetPlatform,
    packageName: installed?.packageName ?? '',
    iosAppStoreId: ref.watch(iosAppStoreIdProvider),
    sourceUrl: ref.watch(sourceUrlProvider),
  );
});

/// Reloads the web page; false where there is none. Tests override it.
final pageReloaderProvider = Provider<bool Function()>(
  (ref) => platform.reloadPage,
);
