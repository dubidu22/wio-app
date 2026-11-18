import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:tonik_util/tonik_util.dart';
import 'package:wio_api/wio_api.dart';

import '../update/app_too_old.dart';
import '../update/app_version.dart';
import 'session.dart';

/// Path of the one operation sent without a token.
const String signInPath = '/auth/sign-in';

/// Header with the installed app's version (D-140, D-151).
const String appVersionHeader = 'Wio-App-Version';

/// Problem code of a too old app (D-142).
const String upgradeRequiredCode = 'upgrade_required';

/// Error bodies up to this size are read for their code (D-152); larger ones
/// are handed on unread.
const int maxInspectedBody = 16 * 1024;

/// What the API client needs from the rest of the app for #33 (D-151,
/// D-152): the installed version and the too-old state.
class ApiHooks {
  const ApiHooks({
    this.appVersion = _noVersion,
    this.tooOld = _notTooOld,
    this.reportTooOld = _ignore,
  });

  /// No version, never too old; for clients outside the app.
  static const ApiHooks none = ApiHooks();

  /// The header value, or null when none is sent.
  final Future<String?> Function() appVersion;

  /// Set once the server said the app is too old.
  final AppTooOld? Function() tooOld;

  /// Called when an answer says the app is too old.
  final void Function(AppTooOld tooOld) reportTooOld;

  static Future<String?> _noVersion() async => null;
  static AppTooOld? _notTooOld() => null;
  static void _ignore(AppTooOld tooOld) {}
}

/// The one HTTP client under every API call (D-133, D-151, D-152):
///
/// * adds `Authorization: Bearer <token>` to every request except sign-in,
///   and only to the server the token came from ([Session.apiBase]), so a
///   build pointed at another server never sends it there;
/// * adds `Wio-App-Version` to every request, sign-in included, so no call
///   site passes it;
/// * recognises `upgrade_required` on any answer (typed 426, or the same
///   code under another status), reports it, and hands the same bytes on;
/// * once the app is too old, answers every request of this run itself with
///   that 426 and sends nothing more.
class AuthClient extends http.BaseClient {
  AuthClient(this._inner, this._session, [this._hooks = ApiHooks.none]);

  final http.Client _inner;
  final Session? Function() _session;
  final ApiHooks _hooks;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final tooOld = _hooks.tooOld();
    if (tooOld != null) return _upgradeRequired(request, tooOld);
    final session = _session();
    if (session != null &&
        !request.url.path.endsWith(signInPath) &&
        isUnderBase(request.url, session.apiBase)) {
      request.headers['Authorization'] = 'Bearer ${session.token}';
    }
    final version = await _hooks.appVersion();
    if (version != null) request.headers[appVersionHeader] = version;
    return _inspect(await _inner.send(request));
  }

  /// Reads a small problem+json error for upgrade_required and hands on a
  /// response with the same status, headers and bytes.
  Future<http.StreamedResponse> _inspect(http.StreamedResponse response) async {
    if (response.statusCode < 400 ||
        !_isProblem(response.headers['content-type']) ||
        (response.contentLength ?? 0) > maxInspectedBody) {
      return response;
    }
    final chunks = StreamIterator<List<int>>(response.stream);
    final head = BytesBuilder(copy: false);
    var complete = true;
    while (await chunks.moveNext()) {
      head.add(chunks.current);
      if (head.length > maxInspectedBody) {
        complete = false;
        break;
      }
    }
    final bytes = head.takeBytes();
    if (complete) {
      final tooOld = _readTooOld(bytes);
      if (tooOld != null) _hooks.reportTooOld(tooOld);
    }
    Stream<List<int>> body() async* {
      yield bytes;
      if (!complete) {
        while (await chunks.moveNext()) {
          yield chunks.current;
        }
      }
    }

    return http.StreamedResponse(
      body(),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  /// The 426 the server would send, made here without a request (D-152).
  http.StreamedResponse _upgradeRequired(
    http.BaseRequest request,
    AppTooOld tooOld,
  ) {
    final bytes = utf8.encode(
      jsonEncode(<String, Object?>{
        'type': 'about:blank',
        'title': 'Update the app',
        'status': 426,
        'code': upgradeRequiredCode,
        if (tooOld.minimumVersion != null)
          'minimum_app_version': tooOld.minimumVersion,
      }),
    );
    return http.StreamedResponse(
      Stream<List<int>>.value(bytes),
      426,
      contentLength: bytes.length,
      request: request,
      headers: const <String, String>{
        'content-type': 'application/problem+json',
      },
    );
  }

  /// The inner client belongs to whoever made it.
  @override
  void close() {}
}

bool _isProblem(String? contentType) =>
    contentType != null &&
    contentType.split(';').first.trim().toLowerCase() ==
        'application/problem+json';

/// The too-old state an error body describes, or null for any other body.
/// A minimum that is not a version is left out rather than shown.
AppTooOld? _readTooOld(List<int> bytes) {
  final Object? json;
  try {
    json = jsonDecode(utf8.decode(bytes));
  } on FormatException {
    return null;
  }
  if (json is! Map<String, Object?> || json['code'] != upgradeRequiredCode) {
    return null;
  }
  final minimum = json['minimum_app_version'];
  return AppTooOld(
    minimumVersion:
        minimum is String &&
            minimum.length <= appVersionMaxLength &&
            appVersionPattern.hasMatch(minimum)
        ? minimum
        : null,
  );
}

/// True when [url] is on the server at [base]: same scheme, host and port,
/// and a path at or below the base path. A plain string prefix would let
/// `https://api.example.org.other.net` pass for `https://api.example.org`.
bool isUnderBase(Uri url, String base) {
  final Uri baseUri;
  try {
    baseUri = Uri.parse(base);
  } on FormatException {
    return false;
  }
  if (!baseUri.hasScheme || baseUri.host.isEmpty) return false;
  if (url.scheme != baseUri.scheme ||
      url.host.toLowerCase() != baseUri.host.toLowerCase() ||
      url.port != baseUri.port) {
    return false;
  }
  final basePath = baseUri.path.endsWith('/')
      ? baseUri.path
      : '${baseUri.path}/';
  return url.path == baseUri.path || url.path.startsWith(basePath);
}

/// The API server at [baseUrl] over [inner], through [AuthClient] with the
/// token of the session [session] returns. Every generated API (auth, sync,
/// files, system) is built on it.
Server buildApiServer(
  String baseUrl,
  http.Client inner,
  Session? Function() session,
  ApiHooks hooks,
) {
  return CustomServer(
    baseUrl: baseUrl,
    serverConfig: ServerConfig<http.Client>.client(
      AuthClient(inner, session, hooks),
    ),
  );
}

/// The generated auth API on [buildApiServer].
AuthApi buildAuthApi(
  String baseUrl,
  http.Client inner,
  Session? Function() session,
  ApiHooks hooks,
) => AuthApi(buildApiServer(baseUrl, inner, session, hooks));
