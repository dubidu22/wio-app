import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../data/queries.dart';
import '../l10n/app_localizations.dart';
import '../shell/back_button.dart';
import '../shell/layout.dart';
import '../shell/providers.dart';

/// Level 2: one customer (KB workflows.md). Sites and rooms come from the
/// local database; entries and pictures are plain hints until their
/// features exist (D-75). The main button "Tag abschließen" comes in M5.
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
        leadingWidth: wioBackButtonWidth,
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
    );
  }
}

class _CustomerBody extends StatelessWidget {
  const _CustomerBody({required this.view});

  final CustomerView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 0, 6),
                child: Text(
                  room.name ?? l10n.unnamedRoom,
                  style: textTheme.bodyLarge,
                ),
              ),
          ],
          SectionHeading(l10n.customerEntries),
          HintText(l10n.customerEntriesEmpty),
          SectionHeading(l10n.customerPictures),
          HintText(l10n.customerPicturesEmpty),
        ],
      ),
    );
  }
}
