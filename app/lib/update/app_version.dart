import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The `Wio-App-Version` pattern of the contract (D-140); a test reads it
/// from api/openapi.yaml.
final RegExp appVersionPattern = RegExp(
  r'^[0-9]{1,9}\.[0-9]{1,9}\.[0-9]{1,9}(\+[0-9]{1,9})?$',
);

/// The header's longest value in the contract.
const int appVersionMaxLength = 32;

/// `major.minor.patch+build` from the build's [version] and [buildNumber]
/// (D-150). The build part is dropped when it is missing, not digits, or
/// would make the value too long; null when the version itself does not fit
/// the contract, so a malformed value is never sent (D-142).
String? normaliseAppVersion(String version, String buildNumber) {
  final full = version.trim();
  if (_fits(full) && full.contains('+')) return full;
  final plain = full.split('+').first;
  final build = buildNumber.trim();
  final withBuild = '$plain+$build';
  if (build.isNotEmpty && _fits(withBuild)) return withBuild;
  return _fits(plain) ? plain : null;
}

bool _fits(String value) =>
    value.length <= appVersionMaxLength && appVersionPattern.hasMatch(value);

/// The installed build: its version for the header (null: not sent) and its
/// package name for the store link (D-153).
class InstalledApp {
  const InstalledApp({required this.version, required this.packageName});

  /// Neither could be read.
  static const InstalledApp unknown = InstalledApp(
    version: null,
    packageName: '',
  );

  final String? version;
  final String packageName;
}

/// Read once from the platform, which takes both from pubspec.yaml's
/// `version:` (D-150). Tests override it.
final installedAppProvider = FutureProvider<InstalledApp>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return InstalledApp(
      version: normaliseAppVersion(info.version, info.buildNumber),
      packageName: info.packageName,
    );
  } on Object {
    // No header is the safe side: the server lets it pass (D-142).
    return InstalledApp.unknown;
  }
});
