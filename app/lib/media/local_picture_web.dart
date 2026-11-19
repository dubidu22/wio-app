import 'package:material_ui/material_ui.dart';

/// The web keeps no picture files in M2 (D-246); #62 decides where
/// downloaded files live there.
ImageProvider? localPicture(String folder, String sha256, {int? cacheWidth}) =>
    null;
