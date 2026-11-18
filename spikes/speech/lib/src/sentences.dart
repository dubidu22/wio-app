/// The fixed test items. Invented sentences with household words and
/// numbers; no customer data. These are test data, not UI text, so they live
/// here and not in the ARB files.
class TestItem {
  const TestItem(this.id, this.reference);

  final String id;

  /// What the speaker reads. Null for the free note, which has no reference.
  final String? reference;

  bool get isFreeNote => reference == null;
}

const testItems = <TestItem>[
  TestItem('s1',
      'Die Kiste mit den Wintersachen steht im Keller im zweiten Regal oben links.'),
  TestItem('s2', 'Im Wohnzimmer fehlen noch drei Bilderhaken und eine Glühbirne.'),
  TestItem('s3', 'Frau Berger möchte, dass die Bücher nach Farben sortiert werden.'),
  TestItem('s4',
      'Der Schrank im Flur ist hundertachtzig Zentimeter hoch und sechzig Zentimeter breit.'),
  TestItem('s5', 'Morgen um neun Uhr kommen zwei Helfer mit dem Transporter.'),
  TestItem('free', null),
];
