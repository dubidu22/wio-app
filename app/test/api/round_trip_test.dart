// The generated client reads and writes the same bytes as the server's
// contract test (plan 004, test 8): every file in api/examples/ decodes with
// the generated classes and encodes back to the same JSON. Old apps must
// survive newer servers (D-96, D-99), so unknown fields, entities and
// open-string values decode too.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wio_api/wio_api.dart';

typedef Codec = Object? Function(Object? json);

/// Decode, then encode again, per contract schema.
final Map<String, Codec> codecs = {
  'SignInRequest': (j) => SignInRequest.fromJson(j).toJson(),
  'SignInResult': (j) => SignInResult.fromJson(j).toJson(),
  'Me': (j) => Me.fromJson(j).toJson(),
  'DeviceList': (j) => DeviceList.fromJson(j).toJson(),
  'Problem': (j) => Problem.fromJson(j).toJson(),
  'FileState': (j) => FileState.fromJson(j).toJson(),
  'PushRequest': (j) => PushRequest.fromJson(j).toJson(),
  'PushResult': (j) => PushResult.fromJson(j).toJson(),
  'PullResult': (j) => PullResult.fromJson(j).toJson(),
};

/// Decode, then encode again, per entity of a pulled record (D-95).
final Map<String, Codec> records = {
  'workspaces': (j) => Workspace.fromJson(j).toJson(),
  'users': (j) => User.fromJson(j).toJson(),
  'customers': (j) => Customer.fromJson(j).toJson(),
  'sites': (j) => Site.fromJson(j).toJson(),
  'rooms': (j) => Room.fromJson(j).toJson(),
  'openings': (j) => Opening.fromJson(j).toJson(),
  'fixtures': (j) => Fixture.fromJson(j).toJson(),
  'entries': (j) => Entry.fromJson(j).toJson(),
  'place_history': (j) => PlaceHistory.fromJson(j).toJson(),
  'pictures': (j) => Picture.fromJson(j).toJson(),
  'notes': (j) => Note.fromJson(j).toJson(),
  'labels': (j) => Label.fromJson(j).toJson(),
  'property_keys': (j) => PropertyKey.fromJson(j).toJson(),
  'entity_labels': (j) => EntityLabel.fromJson(j).toJson(),
  'entity_properties': (j) => EntityProperty.fromJson(j).toJson(),
  'jobs': (j) => Job.fromJson(j).toJson(),
  'time_blocks': (j) => TimeBlock.fromJson(j).toJson(),
  'sign_offs': (j) => SignOff.fromJson(j).toJson(),
  'expenses': (j) => Expense.fromJson(j).toJson(),
  'conflicts': (j) => Conflict.fromJson(j).toJson(),
};

/// Fields only the server sets; read-only in the contract (D-95).
const serverSet = {
  'id',
  'workspace_id',
  'created_at',
  'created_by',
  'updated_at',
  'updated_by',
  'revision',
  'deleted_at',
};

final RegExp _dateTime = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}');

/// Drops nulls (absent and null mean the same in the contract) and writes
/// every date-time as the same instant in UTC, so only content is compared.
Object? normalize(Object? value) {
  if (value is Map) {
    return {
      for (final entry in value.entries)
        if (entry.value != null) entry.key as String: normalize(entry.value),
    };
  }
  if (value is List) {
    return [for (final item in value) normalize(item)];
  }
  if (value is String && _dateTime.hasMatch(value)) {
    return DateTime.parse(value).toUtc().toIso8601String();
  }
  return value;
}

Object? readJson(File file) => jsonDecode(file.readAsStringSync());

void main() {
  final examples =
      Directory('../api/examples')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('there are examples to read', () {
    expect(examples.length, greaterThanOrEqualTo(10));
  });

  for (final file in examples) {
    final name = file.uri.pathSegments.last;
    final schema = name.split('.')[1];

    test('$name decodes and encodes back to the same JSON', () {
      final codec = codecs[schema];
      expect(codec, isNotNull, reason: 'No codec for schema $schema');
      final json = readJson(file);
      final expected = normalize(json) as Map<String, Object?>;
      if (schema == 'Me') {
        // A field this app version does not know is ignored, not an error.
        expect(expected.remove('unknown_later_field'), isNotNull);
      }
      expect(normalize(codec!(json)), expected);
    });
  }

  test('every known entity in a pulled page decodes with its record class', () {
    final page = readJson(
      File('../api/examples/response.PullResult.page.json'),
    ) as Map<String, Object?>;
    final seen = <String>[];
    for (final record
        in (page['records']! as List).cast<Map<String, Object?>>()) {
      final entity = record['entity']! as String;
      final codec = records[entity];
      if (codec == null) {
        // An entity this version does not know: skipped (D-96).
        expect(entity, 'future_things');
        continue;
      }
      // The generated toJson leaves out read-only fields, which only the
      // server sets (D-95); everything else must come back unchanged.
      final expected = normalize(record['fields'])! as Map<String, Object?>
        ..removeWhere((key, _) => serverSet.contains(key));
      expect(normalize(codec(record['fields'])), expected, reason: entity);
      seen.add(entity);
    }
    expect(
      seen,
      containsAll(['customers', 'rooms', 'fixtures', 'entries', 'labels']),
    );
  });

  test('read-only fields are read from a pulled record', () {
    final page = readJson(
      File('../api/examples/response.PullResult.page.json'),
    ) as Map<String, Object?>;
    final room = (page['records']! as List)
        .cast<Map<String, Object?>>()
        .firstWhere((r) => r['entity'] == 'rooms');
    final decoded = Room.fromJson(room['fields']);
    expect(decoded.revision, 3);
    expect(decoded.workspaceId, '01990000-0000-7000-8000-000100000001');
    expect(decoded.createdAt, DateTime.utc(2026, 11, 18, 8));
    expect(decoded.outline!.roomOutline.length, 4);
    expect(decoded.outline!.roomOutline[1].xCm, 320);
  });

  test('open strings survive unknown values (D-96, D-98)', () {
    final push = PushResult.fromJson(
      readJson(File('../api/examples/response.PushResult.mixed.json')),
    );
    expect(push.results.last.reason, 'some_future_reason');
    expect(push.results.last.status, ChangeResultStatusModel.rejected);

    final problem = Problem.fromJson(
      readJson(File('../api/examples/response.Problem.unknown-code.json')),
    );
    expect(problem.code, 'some_future_code');
  });

  test('the largest revision survives on every platform (D-99)', () {
    final pull = PullResult.fromJson(
      readJson(File('../api/examples/response.PullResult.empty-at-max.json')),
    );
    expect(pull.lastRevision, 9007199254740991);
    expect(pull.toJson(), containsPair('last_revision', 9007199254740991));
  });

  test('a new record pushes base_revision as null', () {
    final push = PushRequest.fromJson(
      readJson(File('../api/examples/request.PushRequest.mixed.json')),
    );
    final first = (push.toJson()! as Map<String, Object?>)['changes']! as List;
    expect(
      (first.first as Map<String, Object?>).containsKey('base_revision'),
      isTrue,
    );
    expect((first.first as Map<String, Object?>)['base_revision'], isNull);
  });
}
