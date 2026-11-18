import 'package:http/http.dart' as http;
import 'package:tonik_util/tonik_util.dart';
import 'package:wio_api/wio_api.dart';

/// Path of the one operation sent without a token.
const String signInPath = '/auth/sign-in';

/// The only place the device token is sent (D-133): adds
/// `Authorization: Bearer <token>` to every request except sign-in. The
/// app-version header of #33 goes here too.
class AuthClient extends http.BaseClient {
  AuthClient(this._inner, this._token);

  final http.Client _inner;
  final String? Function() _token;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (!request.url.path.endsWith(signInPath)) {
      final token = _token();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }
    return _inner.send(request);
  }

  /// The inner client belongs to whoever made it.
  @override
  void close() {}
}

/// The generated auth API over [inner], sending the token [token] returns.
AuthApi buildAuthApi(
  String baseUrl,
  http.Client inner,
  String? Function() token,
) {
  return AuthApi(
    CustomServer(
      baseUrl: baseUrl,
      serverConfig: ServerConfig<http.Client>.client(AuthClient(inner, token)),
    ),
  );
}
