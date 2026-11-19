import 'package:wio_app/data/database.dart';

import '../support/test_data.dart';

/// One screen of the app, opened at [location] over [seed]ed data.
class CatalogScreen {
  const CatalogScreen(this.location, {this.seed = seedTestData});

  final String location;
  final Future<void> Function(WioDatabase db) seed;
}

/// Every screen of the app, keyed by its source file under lib/.
/// screens_test.dart checks each one against the UX rules and fails when a
/// file named *_screen.dart is missing here. The golden tests render the
/// same screens, with the demo picture files in the media folder (D-263).
const Map<String, CatalogScreen> screenCatalog = <String, CatalogScreen>{
  'lib/auth/sign_in_screen.dart': CatalogScreen('/anmelden'),
  'lib/jobs/job_list_screen.dart': CatalogScreen('/'),
  'lib/customers/customer_screen.dart': CatalogScreen(
    '/customers/${TestIds.familieBeispiel}',
    seed: seedWithNotes,
  ),
  'lib/rooms/room_screen.dart': CatalogScreen(
    '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.kueche}',
    seed: seedWithNotes,
  ),
  'lib/pictures/picture_screen.dart': CatalogScreen(
    '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.kueche}'
    '/pictures/${TestIds.fotoVorher}',
    seed: seedWithNotes,
  ),
  'lib/notes/note_screen.dart': CatalogScreen(
    '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.kueche}'
    '/notizen/${TestIds.notizSprache}',
    seed: seedWithNotes,
  ),
  'lib/camera/camera_screen.dart': CatalogScreen(
    '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.kueche}/kamera',
    seed: seedWithPictures,
  ),
  'lib/planning/place_screen.dart': CatalogScreen(
    '/customers/${TestIds.familieBeispiel}/entries/${TestIds.kiste}/ort',
    seed: seedWithEntries,
  ),
  'lib/planning/spot_screen.dart': CatalogScreen(
    '/customers/${TestIds.familieBeispiel}/entries/${TestIds.kiste}/ort'
    '/${TestIds.kueche}',
    seed: seedWithEntries,
  ),
  'lib/sync/rejected_screen.dart': CatalogScreen(
    '/nicht-gesendet',
    seed: seedWithRejectedAndUploads,
  ),
  'lib/update/update_required_screen.dart': CatalogScreen('/aktualisieren'),
  'lib/voice/voice_screen.dart': CatalogScreen(
    '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.kueche}/sprechen',
    seed: seedWithPictures,
  ),
};
