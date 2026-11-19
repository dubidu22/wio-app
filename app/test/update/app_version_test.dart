import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wio_app/update/app_version.dart';

/// The Wio-App-Version parameter's text in the contract (D-140).
String contractParameter() {
  final yaml = File('../api/openapi.yaml').readAsStringSync();
  final start = yaml.indexOf('name: Wio-App-Version');
  expect(start, isNot(-1), reason: 'header parameter missing in the contract');
  final end = yaml.indexOf('pattern:', start);
  return yaml.substring(start, yaml.indexOf('\n', end));
}

/// The header pattern as the contract states it.
RegExp contractPattern() {
  final match = RegExp(r"pattern: '([^']+)'").firstMatch(contractParameter());
  expect(match, isNotNull, reason: 'header pattern missing in the contract');
  return RegExp(match!.group(1)!);
}

/// The header's maximum length as the contract states it.
int contractMaxLength() {
  final match = RegExp(r'maxLength: (\d+)').firstMatch(contractParameter());
  expect(match, isNotNull, reason: 'header maxLength missing in the contract');
  return int.parse(match!.group(1)!);
}

/// Plan 038 test 1 (D-150).
void main() {
  readInstalledAppTests();
  test('the app pattern and length are the contract ones', () {
    expect(appVersionPattern.pattern, contractPattern().pattern);
    expect(appVersionMaxLength, contractMaxLength());
  });

  test('version and build number become major.minor.patch+build', () {
    expect(normaliseAppVersion('0.1.0', '1'), '0.1.0+1');
    expect(normaliseAppVersion('12.3.45', '678'), '12.3.45+678');
    expect(normaliseAppVersion(' 0.1.0 ', ' 1 '), '0.1.0+1');
  });

  test('a missing or unusable build number is dropped', () {
    expect(normaliseAppVersion('0.1.0', ''), '0.1.0');
    expect(normaliseAppVersion('0.1.0', 'abc'), '0.1.0');
    expect(normaliseAppVersion('0.1.0', '1234567890'), '0.1.0');
    // pubspec's "+1" may also arrive inside the version on some platforms.
    expect(normaliseAppVersion('0.1.0+7', ''), '0.1.0+7');
    expect(normaliseAppVersion('0.1.0+7', '7'), '0.1.0+7');
    // Longer than the contract allows with the build: the build goes.
    expect(
      normaliseAppVersion('999999999.999999999.999999999', '999999999'),
      '999999999.999999999.999999999',
    );
  });

  test('a version that does not fit the pattern is not sent', () {
    for (final version in <String>[
      '',
      '1.2',
      '1.2.3-beta',
      '1.2.3.4',
      '1234567890.0.0',
      'v1.2.3',
      '1.2.x',
    ]) {
      expect(normaliseAppVersion(version, '1'), isNull, reason: version);
    }
  });

  test('every value that is sent matches the contract pattern', () {
    final pattern = contractPattern();
    final maxLength = contractMaxLength();
    for (final (version, build) in <(String, String)>[
      ('0.1.0', '1'),
      ('0.1.0', ''),
      ('999999999.999999999.999999999', '999999999'),
      ('0.1.0+7', ''),
      ('1.2.3', 'beta'),
    ]) {
      final value = normaliseAppVersion(version, build);
      expect(value, isNotNull);
      expect(pattern.hasMatch(value!), isTrue, reason: value);
      expect(value.length, lessThanOrEqualTo(maxLength), reason: value);
    }
  });
}

/// Plan 097 (D-412, D-413): the platform read never waits long.
void readInstalledAppTests() {
  group('readInstalledApp', () {
    const short = Duration(milliseconds: 20);

    test('a read that never completes gives unknown after the timeout', () async {
      final app = await readInstalledApp(
        () => Completer<PackageInfo>().future,
        timeout: short,
      );
      expect(app.version, isNull);
      expect(app.packageName, '');
    });

    test('a normal read gives version and package name', () async {
      final app = await readInstalledApp(
        () async => PackageInfo(
          appName: 'Wio',
          packageName: 'de.wiederinordnung.app',
          version: '1.2.3',
          buildNumber: '45',
        ),
        timeout: short,
      );
      expect(app.version, '1.2.3+45');
      expect(app.packageName, 'de.wiederinordnung.app');
    });

    test('a read that throws gives unknown', () async {
      final app = await readInstalledApp(
        () async => throw StateError('no version.json'),
        timeout: short,
      );
      expect(app.version, isNull);
    });
  });
}
