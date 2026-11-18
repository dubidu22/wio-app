import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:tonik_util/tonik_util.dart';
import 'package:wio_api/wio_api.dart';

import '../data/database.dart';
import '../shell/providers.dart';
import 'auth_client.dart';
import 'device_name.dart';
import 'session.dart';
import 'token_store.dart';

/// The API's address, set at build time with
/// `--dart-define=WIO_API_URL=https://...` (D-133). Empty until the hosting
/// exists (#10); sign-in then says that no server is set.
const String wioApiUrl = String.fromEnvironment('WIO_API_URL');

/// The API's address. Tests override it.
final apiBaseUrlProvider = Provider<String>((ref) => wioApiUrl);

/// The HTTP client under the API. Tests override it with a fake server.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// Where the session is kept (D-121, D-123). Tests override it.
final tokenStoreProvider = Provider<TokenStore>(
  (ref) => createPlatformTokenStore(),
);

/// The name sent with sign-in (D-125). Tests override it.
final deviceNameProvider = Provider<Future<String> Function()>(
  (ref) => readDeviceName,
);

/// How long a request may take before it counts as no connection (D-128).
const Duration requestTimeout = Duration(seconds: 15);

/// How long Abmelden waits for the server before it signs out anyway (D-132).
const Duration signOutTimeout = Duration(seconds: 5);

/// getMe runs again when the app comes back after this long (D-129).
const Duration recheckAfter = Duration(hours: 1);

/// The auth API with the stored token; null when no server is set.
final authApiProvider = Provider<AuthApi?>((ref) {
  final base = ref.watch(apiBaseUrlProvider);
  if (base.isEmpty) return null;
  return buildAuthApi(
    base,
    ref.watch(httpClientProvider),
    () => ref.read(sessionProvider).value,
  );
});

/// The signed-in session, or null when signed out (D-129, D-130).
final sessionProvider = AsyncNotifierProvider<SessionNotifier, Session?>(
  SessionNotifier.new,
);

class SessionNotifier extends AsyncNotifier<Session?> {
  DateTime? _lastCheck;

  @override
  Future<Session?> build() async {
    // Opening the database first runs its first-start step, which deletes a
    // session left in the iOS keychain by an earlier install (D-122).
    await ref.read(databaseProvider).customSelect('SELECT 1').get();
    final store = ref.read(tokenStoreProvider);
    final session = await store.read();
    // A token belongs to the server that issued it. A build pointed at
    // another server (for example staging installed over production) drops
    // it instead of sending it there; local data stays.
    if (session != null && session.apiBase != ref.read(apiBaseUrlProvider)) {
      await store.delete();
      return null;
    }
    return session;
  }

  /// Keeps a new session after sign-in.
  Future<void> signedIn(Session session) async {
    await ref.read(tokenStoreProvider).write(session);
    state = AsyncData<Session?>(session);
  }

  /// Checks the stored token with getMe, without blocking anything (D-129):
  /// 200 refreshes the names, 401 token_invalid forgets the session and
  /// keeps every local row, anything else changes nothing.
  Future<void> check() async {
    final session = await future;
    final api = ref.read(authApiProvider);
    if (session == null || api == null) return;
    _lastCheck = ref.read(clockProvider)();
    final TonikResult<GetMeResponse, http.Response> result;
    try {
      result = await api.getMe().timeout(requestTimeout);
    } on Object {
      return;
    }
    // The session may have changed while getMe ran.
    if (state.value?.token != session.token) return;
    switch (result) {
      case TonikSuccess(value: GetMeResponse200(:final body)):
        final fresh = session.withMe(body);
        await ref.read(tokenStoreProvider).write(fresh);
        state = AsyncData<Session?>(fresh);
      case TonikSuccess(value: GetMeResponse401(:final body))
          when body.code == 'token_invalid':
        await _forget();
      case _:
        break;
    }
  }

  /// Checks again when the app comes back after [recheckAfter] (D-129).
  Future<void> checkIfStale() async {
    final last = _lastCheck;
    final now = ref.read(clockProvider)();
    if (last == null || now.difference(last) >= recheckAfter) {
      await check();
    }
  }

  /// Abmelden (D-132): tells the server, then forgets the session whatever
  /// the answer, also offline. Local data and the outbox stay.
  Future<void> signOut() async {
    final api = ref.read(authApiProvider);
    if (api != null && state.value != null) {
      try {
        await api.signOut().timeout(signOutTimeout);
      } on Object {
        // The server token stays until it is revoked or idle (D-111).
      }
    }
    await _forget();
  }

  Future<void> _forget() async {
    await ref.read(tokenStoreProvider).delete();
    state = const AsyncData<Session?>(null);
  }
}

/// The workspace whose rows this device holds, or null when it holds none
/// (D-131).
Future<String?> localWorkspaceId(WioDatabase db) async {
  final row = await db.customSelect('''
    SELECT workspace_id FROM customers
    UNION ALL SELECT workspace_id FROM jobs
    UNION ALL SELECT workspace_id FROM sites
    UNION ALL SELECT workspace_id FROM rooms
    UNION ALL SELECT workspace_id FROM sync_state
    LIMIT 1
  ''').getSingleOrNull();
  return row?.read<String>('workspace_id');
}

/// True when the device holds no local rows at all: a fresh install, which
/// starts on the sign-in screen (D-130).
Future<bool> isLocalDatabaseEmpty(WioDatabase db) async {
  if (await localWorkspaceId(db) != null) return false;
  final outbox = await db.customSelect('SELECT 1 FROM outbox LIMIT 1').get();
  return outbox.isEmpty;
}
