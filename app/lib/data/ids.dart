import 'package:uuid/uuid.dart';

/// Makes a new id for a record or a change.
typedef IdGenerator = String Function();

/// UUID v7 in canonical lower-case text, made on the device (D-67).
String newUuidV7() => const Uuid().v7();
