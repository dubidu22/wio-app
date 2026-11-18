/// German number words for normalising transcripts before the word error
/// rate is computed. Covers 0 to 9999, cardinals and ordinals with any
/// ending. "ein", "eine", "einen" are articles and stay words.
library;

const _small = [
  'null', 'eins', 'zwei', 'drei', 'vier', 'fünf', 'sechs', 'sieben', 'acht',
  'neun', 'zehn', 'elf', 'zwölf', 'dreizehn', 'vierzehn', 'fünfzehn',
  'sechzehn', 'siebzehn', 'achtzehn', 'neunzehn',
];
const _tens = [
  '', '', 'zwanzig', 'dreißig', 'vierzig', 'fünfzig', 'sechzig', 'siebzig',
  'achtzig', 'neunzig',
];
const _smallOrdinalStems = [
  '', 'erst', 'zweit', 'dritt', 'viert', 'fünft', 'sechst', 'siebt', 'acht',
  'neunt', 'zehnt', 'elft', 'zwölft', 'dreizehnt', 'vierzehnt', 'fünfzehnt',
  'sechzehnt', 'siebzehnt', 'achtzehnt', 'neunzehnt',
];
const _ordinalEndings = ['e', 'en', 'er', 'es', 'em'];

/// The German cardinal word for [n] (0 to 9999), written as one word.
String germanCardinal(int n) {
  if (n < 0 || n > 9999) throw RangeError.range(n, 0, 9999);
  if (n == 0) return 'null';
  return _compose(n, unitsEnd: 'eins');
}

String _compose(int n, {required String unitsEnd}) {
  final buffer = StringBuffer();
  final thousands = n ~/ 1000;
  final hundreds = (n % 1000) ~/ 100;
  final rest = n % 100;
  if (thousands > 0) {
    buffer.write(thousands == 1 ? 'tausend' : '${_unitPrefix(thousands)}tausend');
  }
  if (hundreds > 0) {
    buffer.write(hundreds == 1 ? 'hundert' : '${_unitPrefix(hundreds)}hundert');
  }
  if (rest > 0) buffer.write(_below100(rest, unitsEnd: unitsEnd));
  return buffer.toString();
}

String _unitPrefix(int n) => n == 1 ? 'ein' : _small[n];

String _below100(int n, {required String unitsEnd}) {
  if (n == 1) return unitsEnd;
  if (n < 20) return _small[n];
  final unit = n % 10;
  final ten = _tens[n ~/ 10];
  return unit == 0 ? ten : '${_unitPrefix(unit)}und$ten';
}

String _ordinalStem(int n) {
  final rest = n % 100;
  if (rest >= 1 && rest <= 19) {
    final head = n - rest;
    return '${head == 0 ? '' : _compose(head, unitsEnd: 'eins')}${_smallOrdinalStems[rest]}';
  }
  return '${_compose(n, unitsEnd: 'eins')}st';
}

final Map<String, int> _lookup = _buildLookup();

Map<String, int> _buildLookup() {
  final map = <String, int>{};
  for (var n = 0; n <= 9999; n++) {
    final cardinal = germanCardinal(n);
    map[cardinal] = n;
    // "einhundert", "eintausend" are common alternatives.
    if (cardinal.startsWith('hundert') || cardinal.startsWith('tausend')) {
      map['ein$cardinal'] = n;
    }
    if (n == 0) continue;
    final stem = _ordinalStem(n);
    for (final e in _ordinalEndings) {
      map['$stem$e'] = n;
      if (stem.startsWith('hundert') || stem.startsWith('tausend')) {
        map['ein$stem$e'] = n;
      }
    }
  }
  return map;
}

/// The number a German number word stands for, or null if it is no number
/// word. Expects a lowercase word without punctuation.
int? parseGermanNumberWord(String word) => _lookup[word];
