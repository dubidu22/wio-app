import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// D-72: Android never copies the app's data to a cloud backup or another
/// device; the local database holds customer data (INV-04).
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();
  final rules = File('android/app/src/main/res/xml/data_extraction_rules.xml')
      .readAsStringSync();

  test('the manifest turns backup off', () {
    final application = RegExp('<application\\b[^>]*>')
        .firstMatch(manifest)![0]!;
    expect(application, contains('android:allowBackup="false"'));
    expect(application, contains('android:fullBackupContent="false"'));
    expect(
      application,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
  });

  test('the extraction rules exclude every domain', () {
    const domains = <String>[
      'root',
      'file',
      'database',
      'sharedpref',
      'external',
    ];
    for (final section in <String>['cloud-backup', 'device-transfer']) {
      final body = RegExp(
        '<$section>(.*?)</$section>',
        dotAll: true,
      ).firstMatch(rules)?[1];
      expect(body, isNotNull, reason: section);
      for (final domain in domains) {
        expect(
          body,
          contains('<exclude domain="$domain" path="." />'),
          reason: '$section $domain',
        );
      }
      expect(body, isNot(contains('<include')), reason: section);
    }
  });
}
