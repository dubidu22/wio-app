import 'session.dart';
import 'token_store_native.dart'
    if (dart.library.js_interop) 'token_store_web.dart'
    as platform;

/// Where the device keeps its session (D-121, D-123, D-124).
abstract interface class TokenStore {
  /// The stored session, or null when there is none or it is unreadable.
  Future<Session?> read();

  Future<void> write(Session session);

  Future<void> delete();
}

/// The store of this platform: keystore or keychain on phones (D-121), the
/// tab's sessionStorage on the web (D-123).
TokenStore createPlatformTokenStore() => platform.createTokenStore();

/// Key of the one stored entry.
const String sessionStorageKey = 'wio_session';
