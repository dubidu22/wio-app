// The app version on every request and upgrade_required on every operation
// (plan 038 tests 2, 3, 4 and 7; D-151, D-152, D-156). No real network; the
// fake server answers from api/examples/.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tonik_util/tonik_util.dart';
import 'package:wio_api/wio_api.dart';
import 'package:wio_app/auth/auth_client.dart';
import 'package:wio_app/auth/session_provider.dart';
import 'package:wio_app/update/app_too_old.dart';
import 'package:wio_app/update/app_version.dart';

import '../support/fake_api.dart';
import '../support/local_rows.dart';

const String testVersion = '0.1.0+1';
const String header = 'Wio-App-Version';

/// A 426 upgrade_required as the server sends it (example file).
FakeAnswer upgradeRequired() =>
    FakeAnswer(426, apiExample('response.Problem.upgrade-required.json'));

/// The providers the API client reads, over [api].
ProviderContainer containerFor(FakeApi api, {String? version = testVersion}) {
  final container = ProviderContainer(
    overrides: [
      installedAppProvider.overrideWith(
        (ref) async =>
            InstalledApp(version: version, packageName: 'org.example.wio'),
      ),
      httpClientProvider.overrideWithValue(api.client),
      apiBaseUrlProvider.overrideWithValue(fakeApiBase),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// The server the app talks to, with the example session's token.
Server serverOf(ProviderContainer container, FakeApi api) => buildApiServer(
  fakeApiBase,
  api.client,
  exampleSession,
  container.read(apiHooksProvider),
);

/// Every operation of the contract, called the way the app calls it: without
/// the generated per-call `wioAppVersion` argument (D-151).
final Map<String, Future<TonikResult<Object?, Object?>> Function(Server)>
operations = <String, Future<TonikResult<Object?, Object?>> Function(Server)>{
  'signIn': (s) => AuthApi(s).signIn(
    body: const SignInRequest(
      email: 'inhaber@example.org',
      password: 'beispiel-passwort',
      deviceName: 'Testtelefon',
    ),
  ),
  'signOut': (s) => AuthApi(s).signOut(),
  'getMe': (s) => AuthApi(s).getMe(),
  'listDevices': (s) => AuthApi(s).listDevices(),
  'revokeDevice': (s) =>
      AuthApi(s).revokeDevice(deviceId: '01970000-0000-7000-8000-0000000000d2'),
  'syncPush': (s) => SyncApi(s).syncPush(body: const PushRequest(changes: [])),
  'syncPull': (s) => SyncApi(s).syncPull(since: 0),
  'getFileState': (s) => FilesApi(s).getFileState(sha256: 'a' * 64),
  'getFile': (s) => FilesApi(s).getFile(sha256: 'a' * 64),
  'putFileChunk': (s) => FilesApi(s).putFileChunk(
    body: const TonikFileBytes(<int>[1, 2, 3]),
    sha256: 'a' * 64,
    contentRange: 'bytes 0-2/3',
  ),
  'getHealth': (s) => SystemApi(s).getHealth(),
};

void main() {
  group('Wio-App-Version (plan 038 test 2, D-151)', () {
    test('the list covers every operation of the contract', () {
      final yaml = File('../api/openapi.yaml').readAsStringSync();
      final ids = RegExp(r'operationId: (\w+)')
          .allMatches(yaml)
          .map((m) => m.group(1))
          .toSet();
      expect(operations.keys.toSet(), ids);
    });

    test('every operation sends the installed version', () async {
      final api = FakeApi();
      final server = serverOf(containerFor(api), api);
      for (final MapEntry(key: name, value: call) in operations.entries) {
        final before = api.requests.length;
        await call(server);
        expect(api.requests.length, before + 1, reason: name);
        expect(api.requests.last.headers[header], testVersion, reason: name);
      }
    });

    test('no version from the build sends no header', () async {
      final api = FakeApi();
      final server = serverOf(containerFor(api, version: null), api);
      for (final MapEntry(key: name, value: call) in operations.entries) {
        await call(server);
        expect(
          api.requests.last.headers.containsKey(header),
          isFalse,
          reason: name,
        );
      }
    });

    test('the app never passes the per-call argument', () {
      final offenders = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => f.readAsStringSync().contains('wioAppVersion:'))
          .map((f) => f.path)
          .toList();
      expect(offenders, isEmpty);
    });
  });

  group('upgrade_required (plan 038 tests 3 and 4, D-152)', () {
    Future<(ProviderContainer, TonikResult<Object?, Object?>)> answer(
      String operation,
      String key,
      FakeAnswer answer,
    ) async {
      final api = FakeApi(<String, Object>{key: answer});
      final container = containerFor(api);
      final result = await operations[operation]!(serverOf(container, api));
      return (container, result);
    }

    for (final (operation, key, type) in <(String, String, Type)>[
      ('signIn', 'POST /auth/sign-in', SignInResponse426),
      ('getMe', 'GET /auth/me', GetMeResponse426),
      ('signOut', 'POST /auth/sign-out', SignOutResponse426),
      ('syncPull', 'GET /sync/pull', SyncPullResponse426),
    ]) {
      test('a typed 426 from $operation turns the state on', () async {
        final (container, result) = await answer(
          operation,
          key,
          upgradeRequired(),
        );
        expect(container.read(appTooOldProvider)?.minimumVersion, '2.0.0');
        // The generated client still reads the same bytes.
        expect(result, isA<TonikSuccess<Object?, Object?>>());
        final value = (result as TonikSuccess<Object?, Object?>).value;
        expect(value.runtimeType, type);
      });
    }

    for (final status in <int>[409, 500]) {
      test('the code under status $status turns the state on', () async {
        final (container, result) = await answer(
          'getMe',
          'GET /auth/me',
          FakeAnswer(status, <String, Object?>{
            ...problemBody(status, 'upgrade_required'),
            'minimum_app_version': '2.0.0',
          }),
        );
        expect(container.read(appTooOldProvider)?.minimumVersion, '2.0.0');
        expect(
          (result as TonikSuccess<Object?, Object?>).value,
          isA<GetMeResponseDefault>(),
        );
      });
    }

    test('a 426 without a minimum still turns the state on', () async {
      final (container, _) = await answer(
        'getHealth',
        'GET /health',
        FakeAnswer.problem(426, 'upgrade_required'),
      );
      expect(container.read(appTooOldProvider), isNotNull);
      expect(container.read(appTooOldProvider)?.minimumVersion, isNull);
    });

    test('a minimum that is not a version is not shown', () async {
      final (container, _) = await answer(
        'getMe',
        'GET /auth/me',
        FakeAnswer(426, <String, Object?>{
          ...problemBody(426, 'upgrade_required'),
          'minimum_app_version': '<b>neu</b>',
        }),
      );
      expect(container.read(appTooOldProvider), isNotNull);
      expect(container.read(appTooOldProvider)?.minimumVersion, isNull);
    });

    test('other codes and large bodies leave the state off', () async {
      for (final fake in <FakeAnswer>[
        FakeAnswer.problem(401, 'token_invalid'),
        FakeAnswer.problem(500, 'internal'),
        // Over 16 KiB: not inspected, handed on unchanged.
        FakeAnswer(500, <String, Object?>{
          ...problemBody(500, 'upgrade_required'),
          'detail': 'x' * 20000,
        }),
        // Not problem+json, for example a proxy's page.
        const FakeAnswer(426, '<html>upgrade_required</html>'),
      ]) {
        final (container, result) = await answer('getMe', 'GET /auth/me', fake);
        expect(container.read(appTooOldProvider), isNull);
        expect(result, isNotNull);
      }
    });

    test('a large problem body arrives whole', () async {
      final api = FakeApi(<String, Object>{
        'GET /auth/me': FakeAnswer(500, <String, Object?>{
          ...problemBody(500, 'internal'),
          'detail': 'ä' * 20000,
        }),
      });
      final result = await AuthApi(serverOf(containerFor(api), api)).getMe();
      final value = (result as TonikSuccess<GetMeResponse, Object?>).value;
      expect((value as GetMeResponseDefault).body.detail, 'ä' * 20000);
    });

    test('a streamed body without a length is read up to the limit', () async {
      // Chunked answers carry no Content-Length; only the first 16 KiB are
      // read, and the rest still arrives.
      for (final (detail, tooOld) in <(String, bool)>[
        ('kurz', true),
        ('x' * 20000, false),
      ]) {
        final bytes = utf8.encode(
          jsonEncode(<String, Object?>{
            ...problemBody(426, 'upgrade_required'),
            'detail': detail,
          }),
        );
        final inner = MockClient.streaming((request, body) async {
          return http.StreamedResponse(
            Stream<List<int>>.fromIterable(<List<int>>[
              for (var i = 0; i < bytes.length; i += 1000)
                bytes.sublist(
                  i,
                  i + 1000 > bytes.length ? bytes.length : i + 1000,
                ),
            ]),
            426,
            headers: <String, String>{
              'content-type': 'application/problem+json; charset=utf-8',
            },
          );
        });
        final container = containerFor(FakeApi());
        final client = AuthClient(
          inner,
          exampleSession,
          container.read(apiHooksProvider),
        );
        final response = await client.get(Uri.parse('$fakeApiBase/auth/me'));
        expect(response.bodyBytes, bytes);
        expect(container.read(appTooOldProvider) != null, tooOld);
      }
    });

    test('after a 426 nothing more is sent in this run', () async {
      final api = FakeApi(<String, Object>{'GET /auth/me': upgradeRequired()});
      final container = containerFor(api);
      final server = serverOf(container, api);
      await AuthApi(server).getMe();
      expect(api.requests, hasLength(1));
      for (final MapEntry(key: name, value: call) in operations.entries) {
        final result = await call(server);
        expect(api.requests, hasLength(1), reason: name);
        // Answered locally with the same 426, so every caller reads it the
        // way it reads the server's.
        final value = (result as TonikSuccess<Object?, Object?>).value;
        expect(value.runtimeType.toString(), endsWith('Response426'));
        final body = (value as dynamic).body as Problem;
        expect(body.code, 'upgrade_required', reason: name);
        expect(body.minimumAppVersion, '2.0.0', reason: name);
      }
    });

    test('the local answer is the same problem+json', () async {
      final api = FakeApi(<String, Object>{'GET /auth/me': upgradeRequired()});
      final container = containerFor(api);
      final client = AuthClient(
        api.client,
        exampleSession,
        container.read(apiHooksProvider),
      );
      await AuthApi(serverOf(container, api)).getMe();
      final response = await client.get(Uri.parse('$fakeApiBase/health'));
      expect(response.statusCode, 426);
      expect(response.headers['content-type'], 'application/problem+json');
      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      expect(body['code'], 'upgrade_required');
      expect(body['minimum_app_version'], '2.0.0');
      expect(api.requests, hasLength(1));
    });
  });

  test(
    'syncPush answering 426 leaves the outbox (plan 038 test 7, D-156)',
    () async {
      final db = await seededWithOutbox();
      addTearDown(db.close);
      final before = await countRows(db);
      expect(before['outbox'], 1);
      final api = FakeApi(<String, Object>{
        'POST /sync/push': upgradeRequired(),
      });
      final container = containerFor(api);
      final result = await SyncApi(serverOf(container, api))
          .syncPush(body: const PushRequest(changes: []));
      expect(
        (result as TonikSuccess<SyncPushResponse, Object?>).value,
        isA<SyncPushResponse426>(),
      );
      expect(container.read(appTooOldProvider), isNotNull);
      expect(await countRows(db), before);
    },
  );
}
