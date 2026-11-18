// D-134: the password and the token never reach print, debugPrint, logs or
// error texts (plan 035, test 13).
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/fake_api.dart';
import '../support/pump.dart';
import '../support/test_data.dart';

const String password = 'geheimes-passwort-der-tests';

void main() {
  test('the auth code has no print, debugPrint or log call', () {
    final calls = RegExp(r'\b(print|debugPrint|log|developer\.log)\s*\(');
    for (final file in Directory('lib/auth').listSync().whereType<File>()) {
      final source = file.readAsStringSync();
      expect(calls.hasMatch(source), isFalse, reason: file.path);
    }
  });

  final answers = <String, Object>{
    'success': FakeAnswer(200, apiExample('response.SignInResult.basic.json')),
    'invalid_credentials': FakeAnswer.problem(401, 'invalid_credentials'),
    'too_many_attempts': FakeAnswer.problem(429, 'too_many_attempts'),
    'a 500 that is not JSON': const FakeAnswer(500, '<html>500</html>'),
    'no signal': noSignal,
  };
  for (final MapEntry(key: name, value: answer) in answers.entries) {
    testWidgets('nothing secret is printed on $name', (tester) async {
      final printed = <String>[];
      final oldDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) => printed.add(message ?? '');
      addTearDown(() => debugPrint = oldDebugPrint);

      await runZoned(
        () async {
          final db = memoryDatabase();
          addTearDown(db.close);
          await pumpWioApp(
            tester,
            db: db,
            location: '/anmelden',
            store: FakeTokenStore(),
            api: FakeApi(<String, Object>{'POST /auth/sign-in': answer}),
          );
          await tester.enterText(
            find.widgetWithText(TextField, 'E-Mail'),
            'inhaber@example.org',
          );
          await tester.enterText(
            find.widgetWithText(TextField, 'Passwort'),
            password,
          );
          await tester.tap(find.widgetWithText(FilledButton, 'Anmelden'));
          await tester.pumpAndSettle();
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => printed.add(line),
        ),
      );

      final token = apiExample('response.SignInResult.basic.json')['token']!;
      final shown = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .join('\n');
      for (final secret in <Object>[password, token]) {
        expect(printed.join('\n'), isNot(contains('$secret')));
        expect(shown, isNot(contains('$secret')));
      }
    });
  }
}
