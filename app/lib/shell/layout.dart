import 'package:material_ui/material_ui.dart';

/// Widest the content gets on tablets and the web (D-76).
const double wioMaxContentWidth = 720;

/// Centres [child] and limits its width on wide screens.
class ContentWidth extends StatelessWidget {
  const ContentWidth({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: wioMaxContentWidth),
        child: child,
      ),
    );
  }
}

/// A section heading on a screen.
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Semantics(
        header: true,
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

/// A plain hint for something that is missing or comes later (D-75).
class HintText extends StatelessWidget {
  const HintText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Shown when the local database cannot be read (D-65). The error text is
/// shown too, so it can be reported; nothing is deleted.
class LoadFailed extends StatelessWidget {
  const LoadFailed({required this.message, required this.error, super.key});

  final String message;
  final Object error;

  @override
  Widget build(BuildContext context) {
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          HintText(message),
          SelectableText(
            '$error',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
