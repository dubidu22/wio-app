import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/app.dart';

void main() {
  testWidgets('the app starts in German and shows the start screen text', (
    tester,
  ) async {
    await tester.pumpWidget(const WioApp());
    await tester.pumpAndSettle();

    expect(find.text('wio'), findsOneWidget);
    expect(find.text('Die neue App entsteht gerade.'), findsOneWidget);
  });
}
