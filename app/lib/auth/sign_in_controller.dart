import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:tonik_util/tonik_util.dart';
import 'package:wio_api/wio_api.dart';

import '../data/database.dart';
import '../shell/providers.dart';
import 'auth_client.dart';
import 'session.dart';
import 'session_provider.dart';

/// The German message the sign-in screen shows (D-128). The screen maps
/// each to its ARB text; server texts are never shown.
enum SignInMessage {
  emptyFields,
  invalidCredentials,
  tooManyAttempts,
  maintenance,
  noConnection,
  invalidRequest,
  serverError,
  noServer,
  otherWorkspace,
}

/// Wait when a 429 has no usable Retry-After: the server's window (D-113).
const Duration defaultRetryWait = Duration(minutes: 15);

/// One step of the sign-in screen.
class SignInState {
  const SignInState({
    this.sending = false,
    this.workspaces = const <WorkspaceRef>[],
    this.message,
    this.retryAt,
    this.done = false,
  });

  /// A request is on its way; a second tap does nothing.
  final bool sending;

  /// Not empty after 409: the workspaces to choose from (D-127).
  final List<WorkspaceRef> workspaces;

  final SignInMessage? message;

  /// After 429: no request before this time (D-128).
  final DateTime? retryAt;

  /// Signed in; the screen goes to the job list.
  final bool done;

  bool get choosingWorkspace => workspaces.isNotEmpty;

  SignInState copyWith({
    bool? sending,
    List<WorkspaceRef>? workspaces,
    SignInMessage? message,
    bool clearMessage = false,
  }) => SignInState(
    sending: sending ?? this.sending,
    workspaces: workspaces ?? this.workspaces,
    message: clearMessage ? null : (message ?? this.message),
    retryAt: retryAt,
    done: done,
  );
}

typedef _Deps = ({
  String apiBase,
  SessionNotifier sessions,
  Session? previous,
  http.Client httpClient,
  WioDatabase db,
});

/// The sign-in screen's logic. Auto-disposed with the screen, which also
/// drops the e-mail and password kept for the workspace step (D-127).
final signInControllerProvider =
    NotifierProvider.autoDispose<SignInController, SignInState>(
      SignInController.new,
    );

class SignInController extends Notifier<SignInState> {
  String _email = '';
  String _password = '';

  @override
  SignInState build() {
    ref.onDispose(_forgetCredentials);
    return const SignInState();
  }

  /// Anmelden (D-126).
  Future<void> submit(String email, String password) async {
    if (state.sending) return;
    if (_waiting()) return;
    if (email.trim().isEmpty || password.isEmpty) {
      state = SignInState(message: SignInMessage.emptyFields);
      return;
    }
    _email = email.trim();
    _password = password;
    await _send(null);
  }

  /// A workspace button after 409 (D-127).
  Future<void> chooseWorkspace(String workspaceId) async {
    if (state.sending || _waiting()) return;
    await _send(workspaceId);
  }

  /// Zurück from the workspace step to the fields; the password is cleared.
  void backToFields() {
    _password = '';
    state = const SignInState();
  }

  bool _waiting() {
    final retryAt = state.retryAt;
    if (retryAt == null) return false;
    if (ref.read(clockProvider)().isBefore(retryAt)) {
      // Repeat the wait without a request.
      state = SignInState(
        message: SignInMessage.tooManyAttempts,
        retryAt: retryAt,
        workspaces: state.workspaces,
      );
      return true;
    }
    return false;
  }

  Future<void> _send(String? workspaceId) async {
    final api = ref.read(authApiProvider);
    if (api == null) {
      state = SignInState(
        message: SignInMessage.noServer,
        workspaces: state.workspaces,
      );
      return;
    }
    // Read now: the screen may close while the request runs, and a closed
    // controller cannot read providers.
    final deps = (
      apiBase: ref.read(apiBaseUrlProvider),
      sessions: ref.read(sessionProvider.notifier),
      previous: ref.read(sessionProvider).value,
      httpClient: ref.read(httpClientProvider),
      db: ref.read(databaseProvider),
    );
    final readDeviceName = ref.read(deviceNameProvider);
    state = state.copyWith(sending: true, clearMessage: true);
    final deviceName = await readDeviceName();
    final TonikResult<SignInResponse, http.Response> result;
    try {
      result = await api
          .signIn(
            body: SignInRequest(
              email: _email,
              password: _password,
              deviceName: deviceName,
              workspaceId: workspaceId,
            ),
          )
          .timeout(requestTimeout);
    } on Object {
      _password = '';
      if (!ref.mounted) return;
      _fail(SignInMessage.noConnection);
      return;
    }
    if (result case TonikSuccess(value: SignInResponse200(:final body))) {
      await _signedIn(body, deps);
      return;
    }
    if (!ref.mounted) {
      _password = '';
      return;
    }
    switch (result) {
      case TonikSuccess(value: SignInResponse200()):
        break;
      case TonikSuccess(value: SignInResponse409(:final body))
          when body.code == 'workspace_choice_required' &&
              (body.workspaces?.isNotEmpty ?? false):
        state = SignInState(workspaces: body.workspaces!);
      case TonikSuccess(value: SignInResponse429(:final body)):
        _tooMany(body.retryAfter);
      case TonikSuccess(value: SignInResponse400(:final body)):
        _fail(messageForCode(body.code));
      case TonikSuccess(value: SignInResponse401(:final body)):
        _fail(messageForCode(body.code));
      case TonikSuccess(value: SignInResponse409(:final body)):
        _fail(messageForCode(body.code));
      case TonikSuccess(value: SignInResponse503()):
        _fail(SignInMessage.maintenance);
      // The update notice for upgrade_required is #38's (D-148); until then
      // it is handled like any other code.
      case TonikSuccess(value: SignInResponse426(:final body)):
        _fail(messageForCode(body.code));
      case TonikSuccess(value: SignInResponseDefault(:final body)):
        _fail(messageForCode(body.code));
      // No answer at all is a connection failure, whatever the client
      // called it.
      case TonikError(type: TonikErrorType.network) ||
          TonikError(response: null):
        _fail(SignInMessage.noConnection);
      case TonikError(:final response?) when response.statusCode == 429:
        // A Retry-After the client could not read: the server's window.
        _tooMany(null);
      case TonikError(:final response?) when response.statusCode == 503:
        _fail(SignInMessage.maintenance);
      case TonikError():
        _fail(SignInMessage.serverError);
    }
  }

  /// Any answer but the 409 choice ends the attempt: the password is
  /// forgotten (D-127) and the screen returns to the fields with the message.
  void _fail(SignInMessage message) {
    _password = '';
    state = SignInState(message: message);
  }

  void _tooMany(int? retryAfterSeconds) {
    final wait = retryAfterSeconds != null && retryAfterSeconds > 0
        ? Duration(seconds: retryAfterSeconds)
        : defaultRetryWait;
    _password = '';
    state = SignInState(
      message: SignInMessage.tooManyAttempts,
      retryAt: ref.read(clockProvider)().add(wait),
    );
  }

  Future<void> _signedIn(SignInResult result, _Deps deps) async {
    final session = Session(
      token: result.token,
      deviceId: result.deviceId,
      user: result.user,
      workspace: result.workspace,
      apiBase: deps.apiBase,
    );
    final local = await localWorkspaceId(deps.db);
    _forgetCredentials();
    if (local != null && local != session.workspace.id) {
      // D-131: never mix two workspaces on one device until #6 can switch.
      // The new token is revoked even when the screen has closed.
      revokeToken(session, deps.httpClient);
      if (ref.mounted) {
        state = const SignInState(message: SignInMessage.otherWorkspace);
      }
      return;
    }
    // Kept even when the screen closed meanwhile: the owner asked for it.
    await deps.sessions.signedIn(session);
    // Signing in again (for example from an /anmelden link on the web)
    // replaces the old session; its token is revoked, not left valid.
    final previous = deps.previous;
    if (previous != null && previous.token != session.token) {
      revokeToken(previous, deps.httpClient);
    }
    if (ref.mounted) state = const SignInState(done: true);
  }

  /// Whether the controller still holds a password; for tests (D-127).
  @visibleForTesting
  bool get holdsPassword => _password.isNotEmpty;

  void _forgetCredentials() {
    _email = '';
    _password = '';
  }
}

/// Revokes a token the device will not keep (D-131). Runs to the end on its
/// own, whatever happens to the screen that started it.
void revokeToken(Session session, http.Client httpClient) {
  final api = buildAuthApi(session.apiBase, httpClient, () => session);
  unawaited(
    api
        .signOut()
        .timeout(signOutTimeout)
        .then<void>((_) {}, onError: (Object _) {}),
  );
}

/// The message for a problem code (D-128); an unknown code is a server
/// error (D-98).
SignInMessage messageForCode(String code) => switch (code) {
  'invalid_credentials' => SignInMessage.invalidCredentials,
  'too_many_attempts' => SignInMessage.tooManyAttempts,
  'maintenance' => SignInMessage.maintenance,
  'invalid_request' => SignInMessage.invalidRequest,
  _ => SignInMessage.serverError,
};
