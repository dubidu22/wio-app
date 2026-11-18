// An app installed today must keep working against a newer server (D-96,
// D-98, D-99): a new enum value in a response decodes as `unknown`, and an
// error status an operation does not list still arrives as problem+json
// with its machine code (plan 004, test 9).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tonik_util/tonik_util.dart';
import 'package:wio_api/wio_api.dart';

Map<String, Object?> readExample(String name) =>
    jsonDecode(File('../api/examples/$name').readAsStringSync())
        as Map<String, Object?>;

/// A sync API whose server answers every request with [status] and [body].
SyncApi syncAnswering(int status, Map<String, Object?> body) {
  final client = MockClient(
    (request) async => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/problem+json'},
    ),
  );
  return SyncApi(
    CustomServer(
      baseUrl: 'https://api.example.org',
      serverConfig: ServerConfig<http.Client>.client(client),
    ),
  );
}

Map<String, Object?> problem(int status, String code) => {
  'type': 'about:blank',
  'title': 'Problem',
  'status': status,
  'code': code,
};

void main() {
  group('a new enum value decodes as unknown (F1)', () {
    test('in a push result', () {
      final json = readExample('response.PushResult.mixed.json');
      final results = (json['results']! as List).cast<Map<String, Object?>>();
      results.last['status'] = 'some_future_status';
      final push = PushResult.fromJson(json);
      expect(push.results.last.status, ChangeResultStatusModel.unknown);
    });

    test('inside a pulled record', () {
      final note = Note.fromJson({
        'id': '01990000-0000-7000-8000-001100000001',
        'workspace_id': '01990000-0000-7000-8000-000100000001',
        'customer_id': null,
        'subject_type': 'some_future_subject',
        'subject_id': '01990000-0000-7000-8000-000700000001',
        'text': 'Notiz',
        'audio_sha256': null,
        'audio_bytes': null,
        'audio_seconds': null,
        'transcript': null,
        'transcript_source': 'some_future_source',
        'created_at': '2026-11-18T08:00:00.000Z',
        'created_by': null,
        'updated_at': '2026-11-18T08:00:00.000Z',
        'updated_by': null,
        'revision': 7,
        'deleted_at': null,
      });
      expect(note.subjectType, NoteSubjectTypeModel.unknown);
      expect(note.transcriptSource, NoteTranscriptSourceModel.unknown);
      expect(note.text, 'Notiz');
    });

    test('in the signed-in workspace', () {
      final json = readExample('response.Me.basic.json');
      (json['workspace']! as Map<String, Object?>)['plan'] = 'some_future_plan';
      expect(Me.fromJson(json).workspace.plan, MeWorkspacePlanModel.unknown);
    });

    test('is never sent back', () {
      expect(
        () => ChangeOpModel.unknown.toJson(),
        throwsA(isA<EncodingException>()),
      );
    });
  });

  group('an error status the operation does not list keeps its code (F2)', () {
    for (final (status, code) in [
      (500, 'internal'),
      (429, 'too_many_attempts'),
      (502, 'some_future_code'),
    ]) {
      test('$status $code', () async {
        final result = await syncAnswering(
          status,
          problem(status, code),
        ).syncPull(since: 0);
        expect(result, isA<TonikSuccess<SyncPullResponse, http.Response>>());
        final response =
            (result as TonikSuccess<SyncPullResponse, http.Response>).value;
        expect(response, isA<SyncPullResponseDefault>());
        expect((response as SyncPullResponseDefault).body.code, code);
      });
    }
  });

  test(
    '426 upgrade_required arrives typed, with the minimum (D-146)',
    () async {
      final result = await syncAnswering(
        426,
        readExample('response.Problem.upgrade-required.json'),
      ).syncPull(since: 42);
      final response =
          (result as TonikSuccess<SyncPullResponse, http.Response>).value;
      expect(response, isA<SyncPullResponse426>());
      final body = (response as SyncPullResponse426).body;
      expect(body.code, 'upgrade_required');
      expect(body.minimumAppVersion, '2.0.0');
    },
  );

  test('the generated client sends no version header unless asked', () async {
    final sent = <http.BaseRequest>[];
    final api = SystemApi(
      CustomServer(
        baseUrl: 'https://api.example.org',
        serverConfig: ServerConfig<http.Client>.client(
          MockClient((request) async {
            sent.add(request);
            return http.Response(
              '{"status":"ok"}',
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      ),
    );
    await api.getHealth();
    await api.getHealth(wioAppVersion: '1.2.3+4');
    expect(sent.first.headers.containsKey('Wio-App-Version'), isFalse);
    expect(sent.last.headers['Wio-App-Version'], '1.2.3+4');
  });

  test('410 resync_required tells the app to pull again from 0 (F4)', () async {
    final result = await syncAnswering(
      410,
      problem(410, 'resync_required'),
    ).syncPull(since: 42);
    final response =
        (result as TonikSuccess<SyncPullResponse, http.Response>).value;
    expect(response, isA<SyncPullResponse410>());
    expect((response as SyncPullResponse410).body.code, 'resync_required');
  });
}
