import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../camera/take_pictures_button.dart';
import '../data/database.dart';
import '../data/queries.dart';
import '../l10n/app_localizations.dart';
import '../pictures/picture_tile.dart';
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';

/// Level 2: one customer (KB workflows.md). Sites come from the local
/// database; each room is a button to its room screen (D-259). "Fotos" lists
/// the customer's pictures without a room; the main button "Fotos" takes
/// such pictures (Q3, D-258, D-271). Entries are a plain hint until they exist (D-75). The main
/// "Tag abschließen" comes in M5 and then takes the main place.
class CustomerScreen extends ConsumerWidget {
  const CustomerScreen({required this.customerId, super.key});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final customer = ref.watch(customerProvider(customerId));
    final name = switch (customer) {
      AsyncData(value: final CustomerView view) =>
        view.name ?? l10n.unnamedCustomer,
      _ => '',
    };
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const WioBackButton(),
        leadingWidth: wioBackButtonWidth(context),
        title: Text(name),
      ),
      body: switch (customer) {
        AsyncData(value: final CustomerView view) => _CustomerBody(view: view),
        AsyncData() => ContentWidth(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HintText(l10n.customerMissing),
          ),
        ),
        AsyncError(:final error) => LoadFailed(
          message: l10n.loadFailed,
          error: error,
        ),
        _ => const SizedBox.shrink(),
      },
      bottomNavigationBar: switch (customer) {
        AsyncData(value: CustomerView()) => TakePicturesBar(
          cameraLocation: '/customers/$customerId/kamera',
        ),
        _ => null,
      },
    );
  }
}

class _CustomerBody extends ConsumerWidget {
  const _CustomerBody({required this.view});

  final CustomerView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final pictures = ref.watch(customerPicturesProvider(view.id));
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          SectionHeading(l10n.customerSites),
          if (view.sites.isEmpty) HintText(l10n.customerSitesEmpty),
          for (final site in view.sites) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                site.name ?? l10n.unnamedSite,
                style: textTheme.titleMedium,
              ),
            ),
            if (site.address != null)
              Text(site.address!, style: textTheme.bodyMedium),
            if (site.rooms.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: HintText(l10n.siteRoomsEmpty),
              ),
            for (final room in site.rooms)
              _RoomButton(customerId: view.id, room: room),
          ],
          SectionHeading(l10n.customerEntries),
          HintText(l10n.customerEntriesEmpty),
          SectionHeading(l10n.customerPictures),
          switch (pictures) {
            AsyncData(value: final List<Picture> list) when list.isEmpty =>
              HintText(l10n.customerPicturesEmpty),
            AsyncData(value: final List<Picture> list) => PictureGrid(
              pictures: list,
              locationOf: (picture) =>
                  '/customers/${view.id}/pictures/${picture.id}',
            ),
            AsyncError(:final error) => LoadFailed(
              message: l10n.loadFailed,
              error: error,
            ),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }
}

/// One room: a full-width button with its name and how many pictures it has
/// (UX rules 1 and 3, D-259, D-264).
class _RoomButton extends StatelessWidget {
  const _RoomButton({required this.customerId, required this.room});

  final String customerId;
  final RoomView room;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 0, 6),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(72),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: () => context.go('/customers/$customerId/rooms/${room.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              room.name ?? l10n.unnamedRoom,
              style: theme.textTheme.titleLarge,
            ),
            Text(
              l10n.roomPictureCount(room.pictureCount),
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
