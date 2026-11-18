import 'german_numbers.dart';

/// Result of a word error rate computation.
class WerResult {
  const WerResult(this.errors, this.referenceWords);

  /// Substitutions + deletions + insertions.
  final int errors;
  final int referenceWords;

  /// errors / referenceWords, or null when there is no reference.
  double? get rate => referenceWords == 0 ? null : errors / referenceWords;
}

List<String> _words(String s) =>
    s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

/// Word-level Levenshtein distance between [reference] and [hypothesis],
/// both already normalised.
WerResult wordErrorRate(String reference, String hypothesis) {
  final ref = _words(reference);
  final hyp = _words(hypothesis);
  var previous = List<int>.generate(hyp.length + 1, (j) => j);
  for (var i = 1; i <= ref.length; i++) {
    final current = List<int>.filled(hyp.length + 1, 0)..[0] = i;
    for (var j = 1; j <= hyp.length; j++) {
      final cost = ref[i - 1] == hyp[j - 1] ? 0 : 1;
      current[j] = [
        previous[j] + 1,
        current[j - 1] + 1,
        previous[j - 1] + cost,
      ].reduce((a, b) => a < b ? a : b);
    }
    previous = current;
  }
  return WerResult(previous[hyp.length], ref.length);
}

final _punctuation = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);

/// Lowercase and strip punctuation only. Used for the raw WER.
String simpleNormalize(String text) => text
    .toLowerCase()
    .replaceAll(_punctuation, ' ')
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty)
    .join(' ');

const _units = {'cm': 'zentimeter', 'mm': 'millimeter', 'm': 'meter', 'kg': 'kilogramm'};

/// Normalisation for the fair WER: lowercase, no punctuation, number words
/// and digits (including ordinals and clock times) become digits, and common
/// unit abbreviations are spelled out.
String normalizeGerman(String text) {
  var s = text.toLowerCase();
  s = s.replaceAllMapped(RegExp(r'\b(\d{1,2}):00\b'), (m) => m[1]!);
  s = s.replaceAllMapped(
      RegExp(r'(\d)(cm|mm|kg|m)\b'), (m) => '${m[1]} ${m[2]}');
  s = s.replaceAll(_punctuation, ' ');
  final out = <String>[];
  for (final word in s.split(RegExp(r'\s+'))) {
    if (word.isEmpty) continue;
    final n = parseGermanNumberWord(word);
    if (n != null) {
      out.add('$n');
    } else if (_units.containsKey(word) && out.isNotEmpty &&
        int.tryParse(out.last) != null) {
      out.add(_units[word]!);
    } else {
      out.add(word);
    }
  }
  return out.join(' ');
}
