// Grid order with after pictures behind their before picture (plan 059
// test T5, D-281).
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/queries.dart';

Picture _picture(String id, {String? afterOf}) => Picture(
  id: id,
  workspaceId: 'w',
  afterOf: afterOf,
  fileSha256: id,
  fileBytes: 1,
  fileMime: 'image/jpeg',
  widthPx: 1,
  heightPx: 1,
);

List<String> _order(List<Picture> pictures) => <String>[
  for (final p in withAfterPicturesBehind(pictures)) p.id,
];

void main() {
  test('no after pictures: the order stays', () {
    expect(_order(<Picture>[_picture('a'), _picture('b')]), <String>['a', 'b']);
  });

  test('an after picture moves right behind its before picture', () {
    expect(
      _order(<Picture>[
        _picture('a'),
        _picture('b'),
        _picture('a2', afterOf: 'a'),
      ]),
      <String>['a', 'a2', 'b'],
    );
  });

  test('several after pictures keep their own order, chains follow', () {
    expect(
      _order(<Picture>[
        _picture('a'),
        _picture('b'),
        _picture('a1', afterOf: 'a'),
        _picture('a2', afterOf: 'a'),
        _picture('a11', afterOf: 'a1'),
      ]),
      <String>['a', 'a1', 'a11', 'a2', 'b'],
    );
  });

  test('an after picture whose before picture is not listed keeps its '
      'place (deleted, or in another room)', () {
    expect(
      _order(<Picture>[
        _picture('a'),
        _picture('x2', afterOf: 'x'),
        _picture('b'),
      ]),
      <String>['a', 'x2', 'b'],
    );
  });

  test('bad data with a cycle or a self link loses no picture', () {
    expect(
      _order(<Picture>[
        _picture('a', afterOf: 'b'),
        _picture('b', afterOf: 'a'),
        _picture('c', afterOf: 'c'),
      ]).toSet(),
      <String>{'a', 'b', 'c'},
    );
  });
}
