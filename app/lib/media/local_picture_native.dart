import 'dart:io';

import 'package:material_ui/material_ui.dart';

import 'media_store.dart';

/// See `local_picture.dart`. No file check here: presence is known
/// (D-332), so no build stats a file (PR 68 N3).
ImageProvider? localPicture(MediaStore store, String? folder, String sha256) =>
    folder == null ? null : FileImage(File('$folder/$sha256'));
