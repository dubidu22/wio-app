import 'package:material_ui/material_ui.dart';

/// A chip made of a button (plan 104): at least 56 px high, labelled, and
/// the chosen state is in the words of [label], never only in colour (D-5).
/// Chosen chips are filled, the others outlined.
class WordChip extends StatelessWidget {
  const WordChip({
    required this.label,
    required this.chosen,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool chosen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    );
    const size = Size(56, 56);
    final child = Text(label);
    return chosen
        ? FilledButton.tonal(
            style: FilledButton.styleFrom(minimumSize: size, shape: shape),
            onPressed: onPressed,
            child: child,
          )
        : OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: size, shape: shape),
            onPressed: onPressed,
            child: child,
          );
  }
}
