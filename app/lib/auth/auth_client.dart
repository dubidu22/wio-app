import 'package:http/http.dart' as http;
import 'package:tonik_util/tonik_util.dart';
import 'package:wio_api/wio_api.dart';

import 'session.dart';

/// Path of the one operation sent without a token.
const String signInPath = '/auth/sign-in';

/// The only place the device token is sent (D-133): adds
/// `Authorization: Bearer <token>` to every request except sign-in, and only
/// to the server the token came from ([Session.apiBase]), so a build pointed
/// at another server never sends it there. The app-version header of #33
/// goes here too.
class AuthClient extends http.BaseClient {
  AuthClient(this._inner, this._session);

  final http.Client _inner;
  final Session? Function() _session;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final session = _session();
    if (session != null &&
        !request.url.path.endsWith(signInPath) &&
        isUnderBase(request.url, session.apiBase)) {
      request.headers['Authorization'] = 'Bearer ${session.token}';
    }
    return _inner.send(request);
  }

  /// The inner client belongs to whoever made it.
  @override
  void close() {}
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

/// The generated auth API at [baseUrl] over [inner], sending the token of
/// the session [session] returns.
AuthApi buildAuthApi(
  String baseUrl,
  http.Client inner,
  Session? Function() session,
) {
  return AuthApi(
    CustomServer(
      baseUrl: baseUrl,
      serverConfig: ServerConfig<http.Client>.client(
        AuthClient(inner, session),
      ),
    ),
  );
}
