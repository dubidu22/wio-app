import 'package:material_ui/material_ui.dart';

import '../shell/layout.dart';

/// The camera's plain hint and its one button (D-269): permission refused
/// or no camera. Shared by the photo camera and the QR scanner.
class CameraProblem extends StatelessWidget {
  const CameraProblem({
    required this.lines,
    required this.button,
    required this.onPressed,
    super.key,
  });

  final List<String> lines;
  final String button;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          for (final line in lines) HintText(line),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
            ),
            onPressed: onPressed,
            child: Text(button),
          ),
        ],
      ),
    );
  }
}
