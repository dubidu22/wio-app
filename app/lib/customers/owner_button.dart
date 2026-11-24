import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../shell/providers.dart';

/// A full-width outlined button that adds or changes a customer, site, room
/// or job (plan 106): 64 px high, a word on it, and only there while the
/// session's role is owner (P2). It opens [location].
class OwnerButton extends ConsumerWidget {
  const OwnerButton({required this.label, required this.location, super.key});

  final String label;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isOwnerProvider)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(64)),
        onPressed: () => context.go(location),
        child: Text(label),
      ),
    );
  }
}

/// Two [OwnerButton]s side by side, so a site's **+ Raum** and **Ort
/// ändern** take one row (plan 106). The words shrink instead of wrapping at
/// large text sizes, as **Sprechen** does.
class OwnerButtonPair extends ConsumerWidget {
  const OwnerButtonPair({
    required this.firstLabel,
    required this.firstLocation,
    required this.secondLabel,
    required this.secondLocation,
    super.key,
  });

  final String firstLabel;
  final String firstLocation;
  final String secondLabel;
  final String secondLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isOwnerProvider)) return const SizedBox.shrink();
    Widget button(String label, String location) => Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(64),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        onPressed: () => context.go(location),
        child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: <Widget>[
          button(firstLabel, firstLocation),
          const SizedBox(width: 12),
          button(secondLabel, secondLocation),
        ],
      ),
    );
  }
}
