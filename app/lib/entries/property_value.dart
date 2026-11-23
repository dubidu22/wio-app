import '../data/database.dart';
import '../data/entry_writer.dart' show decimalPattern;

/// A decimal the user typed, as the contract's text (plan 104, P6): trimmed,
/// a comma taken as the decimal point. Null when it is not a decimal of the
/// contract's pattern (`-?` up to 14 digits, up to 6 decimals).
String? parseNumber(String input) {
  final text = input.trim().replaceFirst(',', '.');
  return decimalPattern.hasMatch(text) ? text : null;
}

/// A value in words (plan 104, P7): a number with a comma, then the unit.
String formatValue(EntityProperty value, PropertyKey key) {
  final number = value.valueNumber;
  final text = number != null
      ? number.replaceFirst('.', ',')
      : (value.valueText ?? '');
  final unit = key.unit?.trim();
  return unit == null || unit.isEmpty ? text : '$text $unit';
}
