import 'package:web/web.dart' as web;

import 'session.dart';
import 'token_store.dart';

TokenStore createTokenStore() => WebSessionTokenStore();

/// Session in the browser tab's sessionStorage (D-123): it survives a reload
/// and is gone when the tab closes; other tabs never see it. Browser storage
/// has no secure enclave, so nothing longer-lived is kept on a shared
/// computer. Cookie auth is a follow-up for M6.
class WebSessionTokenStore implements TokenStore {
  @override
  Future<Session?> read() async {
    final stored = web.window.sessionStorage.getItem(sessionStorageKey);
    if (stored == null) return null;
    final session = Session.tryDecode(stored);
    if (session == null) await delete();
    return session;
  }

  @override
  Future<void> write(Session session) async {
    web.window.sessionStorage.setItem(sessionStorageKey, session.encode());
  }

  @override
  Future<void> delete() async {
    web.window.sessionStorage.removeItem(sessionStorageKey);
  }
}
