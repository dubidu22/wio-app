import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var voice: VoiceChannel?
  private var notePlayer: NotePlayerChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Before any Dart code opens the database or writes a file: the app's
    // data stays out of iCloud backup (D-347, #19).
    do {
      try BackupExclusion.excludeAppData()
    } catch {
      NSLog("wio: could not exclude app data from backup: \(error)")
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // The app's own channels (D-337, D-349); no plugin.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "WioNative") {
      voice?.dispose()
      notePlayer?.dispose()
      voice = VoiceChannel(messenger: registrar.messenger())
      notePlayer = NotePlayerChannel(messenger: registrar.messenger())
    }
  }
}
