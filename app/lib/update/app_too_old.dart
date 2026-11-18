import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The server answered `upgrade_required` (D-152): this app is too old.
class AppTooOld {
  const AppTooOld({this.minimumVersion});

  /// The lowest version the server takes, when it said so.
  final String? minimumVersion;
}

/// Null while the server has not said the app is too old. Set once by the
/// API client and kept in memory for the rest of this run only (D-157); the
/// sync loop (#6) stops while it is set (D-156).
final appTooOldProvider = NotifierProvider<AppTooOldNotifier, AppTooOld?>(
  AppTooOldNotifier.new,
);

class AppTooOldNotifier extends Notifier<AppTooOld?> {
  @override
  AppTooOld? build() => null;

  /// The first report wins; later ones are this client's own local answers.
  void report(AppTooOld tooOld) {
    state ??= tooOld;
  }
}
