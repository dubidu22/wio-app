import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../shell/layout.dart';
import 'camera_providers.dart';

/// The main button "Fotos" of the room and customer screens (UX rule 3,
/// D-258): opens the camera at [cameraLocation] at once (rule 5). Builds
/// nothing where the app takes no pictures (the web, D-274).
class TakePicturesBar extends ConsumerWidget {
  const TakePicturesBar({required this.cameraLocation, super.key});

  final String cameraLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(canTakePicturesProvider)) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      child: Align(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: wioMaxContentWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(64),
              ),
              onPressed: () => context.go(cameraLocation),
              child: Text(AppLocalizations.of(context).takePictures),
            ),
          ),
        ),
      ),
    );
  }
}
