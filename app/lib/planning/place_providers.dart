import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shell/providers.dart';
import 'place_choices.dart';

/// Key of an entry below a customer in the routes (D-451).
typedef EntryKey = ({String customerId, String entryId});

/// Reading the local database again does not fix a broken one (D-65).
Duration? _noRetry(int retryCount, Object error) => null;

/// The entry and its customer's sites and rooms for the pickers; null when
/// the entry does not exist (plan 107).
final placeChoicesProvider = StreamProvider.family<PlaceChoices?, EntryKey>(
  retry: _noRetry,
  (ref, key) => watchPlaceChoices(
    ref.watch(databaseProvider),
    key.customerId,
    key.entryId,
  ),
);
