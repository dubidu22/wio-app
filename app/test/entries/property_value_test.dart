// The two pure helpers of the property screens (plan 104, P6, P7).
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/entries/property_value.dart';

PropertyKey _key(String? unit) =>
    PropertyKey(id: 'k', workspaceId: 'w', name: 'Gewicht', unit: unit);

EntityProperty _value({String? text, String? number}) => EntityProperty(
  id: 'v',
  workspaceId: 'w',
  entityType: 'entry',
  entityId: 'e',
  keyId: 'k',
  valueText: text,
  valueNumber: number,
);

void main() {
  test('parseNumber takes a comma, trims and keeps the contract pattern', () {
    expect(parseNumber('2,5'), '2.5');
    expect(parseNumber(' 12 '), '12');
    expect(parseNumber('-3'), '-3');
    expect(parseNumber('0.000001'), '0.000001');
    expect(parseNumber('1.2.3'), isNull);
    expect(parseNumber('1,2,3'), isNull);
    expect(parseNumber(''), isNull);
    expect(parseNumber('.5'), isNull);
    expect(parseNumber('abc'), isNull);
    expect(parseNumber('1234567890123'), '1234567890123');
    expect(parseNumber('123456789012345'), isNull);
    expect(parseNumber('1.1234567'), isNull);
  });

  test('formatValue shows a number with a comma and the unit', () {
    expect(formatValue(_value(number: '2.5'), _key('kg')), '2,5 kg');
    expect(formatValue(_value(number: '12'), _key(null)), '12');
    expect(formatValue(_value(number: '12'), _key('  ')), '12');
    expect(formatValue(_value(text: 'Porzellan'), _key(null)), 'Porzellan');
    expect(formatValue(_value(text: 'rot'), _key('kg')), 'rot kg');
  });
}
