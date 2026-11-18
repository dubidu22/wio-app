import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wio_api/wio_api.dart';
import 'package:wio_app/auth/session.dart';
import 'package:wio_app/auth/token_store.dart';

/// Base URL of the fake server; nothing is ever sent to it.
const String fakeApiBase = 'https://api.example.org';

/// Reads one file of `api/examples/` (plan 004): the fake server answers
/// with the same bytes the server's contract tests use.
Map<String, Object?> apiExample(String name) =>
    jsonDecode(File('../api/examples/$name').readAsStringSync())
        as Map<String, Object?>;

/// A problem+json body with [code] (D-98).
Map<String, Object?> problemBody(int status, String code) => <String, Object?>{
  'type': 'about:blank',
  'title': 'Problem',
  'status': status,
  'code': code,
};

/// One scripted answer of the fake server.
class FakeAnswer {
  const FakeAnswer(this.status, [this.body, this.headers = const {}]);

  /// A problem+json answer.
  FakeAnswer.problem(int status, String code, {Map<String, String>? headers})
    : this(status, problemBody(status, code), headers ?? const {});

  final int status;
  final Object? body;
  final Map<String, String> headers;
}

/// Thrown by the fake server instead of answering: no signal, as the real
/// client reports it.
final Exception noSignal = http.ClientException('no signal (fake)');

/// The fake API server (lessons-from-v1: a fake for every external
/// service). Answers by "METHOD /path" from [answers]; an answer can also be
/// [noSignal], a `Completer` the test completes later, or a list of
/// answers given in order, or another `http.Client` that answers instead
/// (for example the fake sync server's). A String body is sent as it is. Defaults are the
/// example files: sign-in 200, getMe 200, sign-out 204. Records every
/// request.
class FakeApi {
  FakeApi([Map<String, Object> answers = const {}])
    : answers = <String, Object>{
        'POST /auth/sign-in': FakeAnswer(
          200,
          apiExample('response.SignInResult.basic.json'),
        ),
        'GET /auth/me': FakeAnswer(200, apiExample('response.Me.basic.json')),
        'POST /auth/sign-out': const FakeAnswer(204),
        ...answers,
      };

  final Map<String, Object> answers;
  final List<http.Request> requests = <http.Request>[];

  /// Requests to [path], in order.
  List<http.Request> to(String path) =>
      requests.where((r) => r.url.path == path).toList();

  /// Bodies of the sign-in requests, decoded.
  List<Map<String, Object?>> get signInBodies => <Map<String, Object?>>[
    for (final r in to('/auth/sign-in'))
      jsonDecode(r.body) as Map<String, Object?>,
  ];

  late final http.Client client = MockClient((request) async {
    requests.add(request);
    final key = '${request.method} ${request.url.path}';
    var answer = answers[key];
    // A list answers in order; its last answer repeats.
    if (answer is List<Object>) {
      answer = answer.length > 1 ? answer.removeAt(0) : answer.first;
    }
    if (answer is Completer<FakeAnswer>) answer = await answer.future;
    if (answer is http.Client) {
      // A sent request cannot be sent again; the other client gets a copy.
      final copy = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..bodyBytes = request.bodyBytes;
      return http.Response.fromStream(await answer.send(copy));
    }
    if (answer is FakeAnswer) {
      final body = answer.body;
      // UTF-8 bytes, as the server sends them; a String body would be encoded
      // as Latin-1 without a charset in the content type.
      return http.Response.bytes(
        utf8.encode(switch (body) {
          null => '',
          final String raw => raw,
          _ => jsonEncode(body),
        }),
        answer.status,
        headers: <String, String>{
          if (body != null && body is! String)
            'content-type': answer.status >= 400
                ? 'application/problem+json'
                : 'application/json',
          ...answer.headers,
        },
      );
    }
    if (answer is Exception) throw answer;
    return http.Response('not found', 404);
  });
}

/// The session the example files describe.
Session exampleSession({String token = 'wio_example-token-of-the-tests'}) {
  final result = SignInResult.fromJson(
    apiExample('response.SignInResult.basic.json'),
  );
  return Session(
    token: token,
    deviceId: result.deviceId,
    user: result.user,
    workspace: result.workspace,
    apiBase: fakeApiBase,
  );
}

/// The token store in memory.
class FakeTokenStore implements TokenStore {
  FakeTokenStore([this.session]);

  Session? session;
  int deletes = 0;

  @override
  Future<Session?> read() async => session;

  @override
  Future<void> write(Session session) async => this.session = session;

  @override
  Future<void> delete() async {
    deletes++;
    session = null;
  }
}
