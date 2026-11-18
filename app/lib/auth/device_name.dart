import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Longest device name the contract takes.
const int maxDeviceNameLength = 100;

/// Used when the platform tells nothing.
const String fallbackDeviceName = 'Gerät';

/// The name sent with sign-in, for the device list (D-125): the maker and
/// model on Android, the model id on iOS (never the name the user gave the
/// phone, which often holds a person's name), the browser on the web.
String describeDevice({String? manufacturer, String? model, String? browser}) {
  final parts = <String>[
    for (final part in <String?>[manufacturer, model, browser])
      if (part != null && part.trim().isNotEmpty) part.trim(),
  ];
  // "Google Pixel 8" rather than "Google Google Pixel 8".
  if (parts.length == 2 &&
      parts[1].toLowerCase().startsWith(parts[0].toLowerCase())) {
    parts.removeAt(0);
  }
  final name = parts.join(' ');
  if (name.isEmpty) return fallbackDeviceName;
  return name.length <= maxDeviceNameLength
      ? name
      : name.substring(0, maxDeviceNameLength);
}

/// Reads the device name from the platform; falls back to "Gerät".
Future<String> readDeviceName() async {
  try {
    final plugin = DeviceInfoPlugin();
    if (kIsWeb) {
      final info = await plugin.webBrowserInfo;
      return describeDevice(browser: 'Browser ${info.browserName.name}');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final info = await plugin.androidInfo;
        return describeDevice(
          manufacturer: info.manufacturer,
          model: info.model,
        );
      case TargetPlatform.iOS:
        final info = await plugin.iosInfo;
        // utsname.machine is the model id, for example "iPhone16,1".
        return describeDevice(model: info.utsname.machine);
      case _:
        return fallbackDeviceName;
    }
  } on Object {
    return fallbackDeviceName;
  }
}
