// The generated client must be regenerated whenever api/openapi.yaml changes
// (D-92): api/generate-dart-client.sh records the contract's SHA-256 next to
// the generated code, and this test compares it with the current contract.
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the generated client was made from the current contract', () {
    final contract = File('../api/openapi.yaml').readAsBytesSync();
    final recorded = File('packages/wio_api/CONTRACT_SHA256')
        .readAsStringSync()
        .trim();

    expect(
      sha256.convert(contract).toString(),
      recorded,
      reason: 'api/openapi.yaml changed: run api/generate-dart-client.sh',
    );
  });
}
