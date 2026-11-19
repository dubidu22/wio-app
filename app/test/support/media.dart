import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Invented demo picture files of `tools/demo/media/` (D-262), by hash.
abstract final class DemoFiles {
  static const String folder = '../tools/demo/media';
  static const String kuecheVorher =
      '6d50de34a9ba213d8ec751b72ba1b21c9fa8a1e939d2bf63146cc5a1edb7c97f';
  static const String kuecheRegal =
      'b3b82cccb169950ea2873530fb54b238757c8c49adee8c4c567dbabb93ee9ba8';
  static const String kuecheNachher =
      '314d114df4b1d7aca55e349198b3467adb683a2977e39fdf6fccc98cac254828';
  static const String kellerRegal =
      '057c779054bb3d8e8555e8d075de6c3639e6b3e06f9f52536f3b811e574637fe';
  static const String flurKartons =
      '1cb7a50aa7ce7c759fac56b83ca01b60341bc04d9cf02fe61d2a678055b6bfe7';

  /// A hash whose file is on no device (D-260).
  static const String missing =
      'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc';
}

/// A temporary media folder (D-240) holding the demo picture files under
/// their hash, as the app keeps them. Call it inside a test: the folder is
/// deleted when the test ends.
String demoMediaFolder() {
  final target = Directory.systemTemp.createTempSync('wio-media-');
  addTearDown(() => target.deleteSync(recursive: true));
  for (final file in Directory(DemoFiles.folder).listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    if (name.endsWith('.jpg')) {
      file.copySync('${target.path}/${name.replaceAll('.jpg', '')}');
    }
  }
  return target.path;
}

/// Reads and decodes every picture on screen for real. File reads and image
/// decoding started inside the fake time of widget tests never finish, so
/// each image is dropped from the cache, loaded again in real time, and the
/// screen's images are told to look it up again (reassemble).
Future<void> loadPictures(WidgetTester tester) async {
  final images = find.byType(Image).evaluate().toList();
  if (images.isEmpty) {
    return;
  }
  await tester.runAsync(() async {
    for (final element in images) {
      final image = (element.widget as Image).image;
      await image.evict();
      await precacheImage(image, element);
    }
  });
  // Completes only after a frame, which pumpAndSettle below draws.
  unawaited(tester.binding.reassembleApplication());
  await tester.pumpAndSettle();
}
