import 'package:flutter_test/flutter_test.dart';
import 'package:speech_spike/src/german_numbers.dart';

void main() {
  test('cardinals', () {
    expect(germanCardinal(0), 'null');
    expect(germanCardinal(1), 'eins');
    expect(germanCardinal(16), 'sechzehn');
    expect(germanCardinal(17), 'siebzehn');
    expect(germanCardinal(21), 'einundzwanzig');
    expect(germanCardinal(30), 'dreißig');
    expect(germanCardinal(101), 'hunderteins');
    expect(germanCardinal(180), 'hundertachtzig');
    expect(germanCardinal(1999), 'tausendneunhundertneunundneunzig');
  });

  test('parse cardinals, ordinals and their endings', () {
    expect(parseGermanNumberWord('hundertachtzig'), 180);
    expect(parseGermanNumberWord('einhundertachtzig'), 180);
    expect(parseGermanNumberWord('zweiten'), 2);
    expect(parseGermanNumberWord('ersten'), 1);
    expect(parseGermanNumberWord('dritte'), 3);
    expect(parseGermanNumberWord('siebter'), 7);
    expect(parseGermanNumberWord('zwanzigsten'), 20);
    expect(parseGermanNumberWord('hunderterste'), 101);
  });

  test('words that are not numbers', () {
    expect(parseGermanNumberWord('ein'), isNull);
    expect(parseGermanNumberWord('eine'), isNull);
    expect(parseGermanNumberWord('einen'), isNull);
    expect(parseGermanNumberWord('regal'), isNull);
  });
}
