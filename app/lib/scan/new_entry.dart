import 'dart:convert';

import '../data/database.dart';
import '../data/entry_writer.dart';

/// Where **+ Eintrag** was tapped: a customer, and its room when it was the
/// room screen (D-465).
typedef NewEntryFrom = ({String customerId, String? roomId});

/// The entry a scan or **Ohne Code** leads to: a new one ([created]) or the
/// live one that already had the code (D-428), with the customer whose
/// path opens it.
typedef EntryFound = ({String customerId, String entryId, bool created});

/// Whether [code] fits `entries.code` (at most 255 UTF-8 bytes, D-51).
/// A longer code is not shortened (D-469).
bool codeFits(String code) =>
    utf8.encode(code).length <= EntryWriter.maxCodeBytes;

/// Opens the live entry that has [code], else creates an entry with it
/// (or without a code when [code] is null) for [from]'s customer. From a
/// room, the new entry is placed on that room's floor in the same
/// transaction (D-424, D-425, D-450). Codes are taken unchanged (D-51).
///
/// Throws [ArgumentError] when the customer or room is gone.
Future<EntryFound> findOrCreateEntry(
  WioDatabase db,
  EntryWriter writer,
  NewEntryFrom from, {
  String? code,
}) async {
  if (code != null) {
    final twin = await writer.entryWithCode(code);
    if (twin != null) return _found(twin, from);
  }
  final customer = await (db.select(
    db.customers,
  )..where((c) => c.id.equals(from.customerId))).getSingleOrNull();
  if (customer == null || customer.deletedAt != null) {
    throw ArgumentError.value(from.customerId, 'customerId', 'no customer');
  }
  var place = Place.none;
  final roomId = from.roomId;
  if (roomId != null) {
    final room = await (db.select(
      db.rooms,
    )..where((r) => r.id.equals(roomId))).getSingleOrNull();
    if (room == null || room.deletedAt != null) {
      throw ArgumentError.value(roomId, 'roomId', 'no room');
    }
    place = Place.room(siteId: room.siteId, roomId: roomId);
  }
  try {
    final id = await writer.createEntry(
      workspaceId: customer.workspaceId,
      customerId: customer.id,
      code: code,
      place: place,
    );
    return (customerId: customer.id, entryId: id, created: true);
  } on DuplicateCode catch (duplicate) {
    // Another write took the code between the lookup and the create.
    final twin = await (db.select(
      db.entries,
    )..where((e) => e.id.equals(duplicate.existingId))).getSingle();
    return _found(twin, from);
  }
}

/// An entry of no customer (personal workspace) opens under the customer
/// where it was scanned; the entry screen reads it by id.
EntryFound _found(Entry entry, NewEntryFrom from) => (
  customerId: entry.customerId ?? from.customerId,
  entryId: entry.id,
  created: false,
);
