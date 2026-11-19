import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../shell/layout.dart';
import '../voice/voice_providers.dart';
import 'camera_providers.dart';

/// The bottom bar of the room and customer screens: the main button
/// "Fotos" (UX rule 3, D-258) opens the camera at [cameraLocation] at once
/// (rule 5); next to it the secondary button "Sprechen" opens the voice note
/// at [speakLocation] (D-295). Builds nothing where the app takes no
/// pictures (the web, D-274); "Sprechen" only where it records (Android).
class TakePicturesBar extends ConsumerWidget {
  const TakePicturesBar({
    required this.cameraLocation,
    this.speakLocation,
    super.key,
  });

  final String cameraLocation;
  final String? speakLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(canTakePicturesProvider)) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final speak = speakLocation;
    final fotos = FilledButton(
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
      onPressed: () => context.go(cameraLocation),
      child: Text(l10n.takePictures),
    );
    return SafeArea(
      child: Align(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: wioMaxContentWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: speak == null || !ref.watch(canRecordVoiceProvider)
                ? fotos
                : Row(
                    children: <Widget>[
                      Expanded(child: SpeakButton(location: speak)),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: fotos),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// The secondary button "Sprechen" (D-295): opens the voice note at
/// [location], which records at once (D-288).
class SpeakButton extends StatelessWidget {
  const SpeakButton({required this.location, super.key});

  final String location;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        // Narrow sides so the word keeps its size at a third of the bar.
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      onPressed: () => context.go(location),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(AppLocalizations.of(context).voiceSpeak),
      ),
    );
  }
}
