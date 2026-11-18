import 'package:flutter_test/flutter_test.dart';
import 'package:speech_spike/src/wer.dart';

void main() {
  group('wordErrorRate', () {
    test('identical text has no errors', () {
      final r = wordErrorRate('eins zwei drei', 'eins zwei drei');
      expect(r.errors, 0);
      expect(r.referenceWords, 3);
      expect(r.rate, 0);
    });

    test('one substitution in four words is 25 percent', () {
      final r = wordErrorRate('a b c d', 'a x c d');
      expect(r.errors, 1);
      expect(r.rate, closeTo(0.25, 1e-9));
    });

    test('insertions and deletions count as errors', () {
      expect(wordErrorRate('a b c', 'a b c d e').errors, 2);
      expect(wordErrorRate('a b c', 'a').errors, 2);
    });

    test('empty hypothesis is 100 percent', () {
      final r = wordErrorRate('a b c', '');
      expect(r.errors, 3);
      expect(r.rate, 1);
    });

    test('empty reference has no rate', () {
      expect(wordErrorRate('', 'a').rate, isNull);
      expect(wordErrorRate('', '').rate, isNull);
    });

    test('rate can exceed 100 percent with many insertions', () {
      expect(wordErrorRate('a', 'a b c').rate, closeTo(2, 1e-9));
    });
  });

  group('normalizeGerman', () {
    test('lowercases and drops punctuation', () {
      expect(normalizeGerman('Frau Berger möchte, dass ...!'),
          'frau berger möchte dass');
    });

    test('number words and digits meet in the middle', () {
      expect(normalizeGerman('hundertachtzig Zentimeter'), '180 zentimeter');
      expect(normalizeGerman('180 cm'), '180 zentimeter');
      expect(normalizeGerman('180cm'), '180 zentimeter');
      expect(normalizeGerman('drei Bilderhaken'), '3 bilderhaken');
    });

    test('ordinals map to the same number as digits with a dot', () {
      expect(normalizeGerman('im zweiten Regal'), 'im 2 regal');
      expect(normalizeGerman('im 2. Regal'), 'im 2 regal');
    });

    test('clock times', () {
      expect(normalizeGerman('um 9:00 Uhr'), 'um 9 uhr');
      expect(normalizeGerman('um neun Uhr'), 'um 9 uhr');
    });

    test('articles that look like numbers stay words', () {
      expect(normalizeGerman('eine Glühbirne'), 'eine glühbirne');
      expect(normalizeGerman('ein Helfer'), 'ein helfer');
    });

    test('keeps umlauts and sharp s', () {
      expect(normalizeGerman('Größe, Fuß'), 'größe fuß');
    });
  });

  test('normalised WER forgives number spelling but raw WER does not', () {
    const ref =
        'Der Schrank im Flur ist hundertachtzig Zentimeter hoch und sechzig Zentimeter breit.';
    const hyp = 'der Schrank im Flur ist 180 cm hoch und 60 cm breit';
    expect(wordErrorRate(normalizeGerman(ref), normalizeGerman(hyp)).errors, 0);
    expect(wordErrorRate(simpleNormalize(ref), simpleNormalize(hyp)).errors,
        greaterThan(0));
  });
}
