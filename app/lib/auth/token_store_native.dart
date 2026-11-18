import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session.dart';
import 'token_store.dart';

/// Android: the default ciphers, an AES-GCM key wrapped with RSA-OAEP in the
/// Android Keystore. The encrypted file is a shared-preferences file, which
/// the D-72 extraction rules keep out of every backup and device transfer.
const AndroidOptions wioAndroidOptions = AndroidOptions.defaultOptions;

/// iOS: readable after the first unlock, and only on this device, so the item
/// never goes to iCloud Keychain or to a backup restored elsewhere (D-121).
const IOSOptions wioIosOptions = IOSOptions(
  accessibility: KeychainAccessibility.first_unlock_this_device,
);

TokenStore createTokenStore() => SecureTokenStore(
  const FlutterSecureStorage(
    aOptions: wioAndroidOptions,
    iOptions: wioIosOptions,
  ),
);

/// Session in the Android Keystore or the iOS keychain (D-121).
class SecureTokenStore implements TokenStore {
  SecureTokenStore(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<Session?> read() async {
    final String? stored;
    try {
      stored = await _storage.read(key: sessionStorageKey);
    } on Object {
      // A key the keystore lost (for example after a restore) cannot be
      // read again; the owner signs in once more.
      await delete();
      return null;
    }
    if (stored == null) return null;
    final session = Session.tryDecode(stored);
    if (session == null) await delete();
    return session;
  }

  @override
  Future<void> write(Session session) =>
      _storage.write(key: sessionStorageKey, value: session.encode());

  @override
  Future<void> delete() async {
    try {
      await _storage.delete(key: sessionStorageKey);
    } on Object {
      // Nothing more to delete.
    }
  }
}
