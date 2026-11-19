import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/entry_writer.dart';
import 'package:wio_app/l10n/app_localizations_de.dart';
import 'package:wio_app/planning/place_words.dart';

void main() {
  final l10n = AppLocalizationsDe();
  const names = <String, String?>{'k': 'Küche', 'u': null};
  bool live(String id) => names.containsKey(id);
  String? name(String id) => names[id];

  String place(Place p) =>
      placeWords(l10n, p, isLiveRoom: live, roomName: name);
  String target(Place p) =>
      targetWords(l10n, p, isLiveRoom: live, roomName: name);

  test('a place in words (D-450, D-456)', () {
    expect(place(Place.none), 'Noch nicht abgelegt');
    expect(place(const Place.room(siteId: 's', roomId: 'k')), 'Küche, Boden');
    expect(
      place(const Place.room(siteId: 's', roomId: 'u')),
      'Raum ohne Namen, Boden',
    );
    expect(place(const Place.room(siteId: 's', roomId: 'x')), 'Raum gelöscht');
  });

  test('a target in words', () {
    expect(target(Place.none), 'Kein Ziel');
    expect(target(const Place.room(siteId: 's', roomId: 'k')), 'Ziel: Küche');
    expect(
      target(const Place.room(siteId: 's', roomId: 'x')),
      'Ziel: Raum gelöscht',
    );
  });

  test("an entry's name: title, else code, else a plain word", () {
    Entry entry({String? title, String? code}) =>
        Entry(id: 'e', workspaceId: 'w', title: title, code: code);
    expect(entryName(l10n, entry(title: 'Kiste', code: 'C1')), 'Kiste');
    expect(entryName(l10n, entry(title: ' ', code: 'C1')), 'C1');
    expect(entryName(l10n, entry()), 'Eintrag ohne Namen');
  });
}
