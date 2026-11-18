import 'package:material_ui/material_ui.dart';

/// Minimum height and width of every touch target (UX rule 3).
const minTouchTarget = 56.0;

/// A full-width button with a word on it (UX rules 1 and 3).
class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 64)),
      textStyle: WidgetStatePropertyAll(Theme.of(context)
          .textTheme
          .labelLarge!
          .copyWith(fontSize: 20, fontWeight: FontWeight.w600)),
      padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
    );
    final child = Text(label, textAlign: TextAlign.center);
    return primary
        ? FilledButton(style: style, onPressed: onPressed, child: child)
        : OutlinedButton(style: style, onPressed: onPressed, child: child);
  }
}

/// "Zurück" as a worded button, top left (UX rules 1 and 2).
class BackTextButton extends StatelessWidget {
  const BackTextButton({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => TextButton(
        style: ButtonStyle(
          minimumSize:
              const WidgetStatePropertyAll(Size(minTouchTarget, minTouchTarget)),
          textStyle: WidgetStatePropertyAll(
              Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 18)),
        ),
        onPressed: () => Navigator.of(context).maybePop(),
        child: Text(label),
      );
}

AppBar spikeAppBar(BuildContext context, String title, {String? backLabel}) => AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: backLabel == null ? null : 120,
      leading: backLabel == null ? null : BackTextButton(label: backLabel),
      title: Text(title),
    );
