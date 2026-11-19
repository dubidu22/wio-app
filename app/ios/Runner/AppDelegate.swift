import BackgroundTasks
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// The app's one engine (D-373), shared by the screen and background
  /// sync, so there is one database connection and one sync run at a time.
  /// It starts when the scene connects or when iOS starts a background
  /// task, whichever comes first.
  let engine = FlutterEngine(name: "wio", project: nil, allowHeadlessExecution: true)
  private var engineStarted = false
  private var voice: VoiceChannel?
  private var notePlayer: NotePlayerChannel?
  private var background: BackgroundSync?

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
    // Task handlers must be registered before launch ends (D-380). iOS
    // calls them on a background queue.
    for identifier in [BackgroundPlan.syncTask, BackgroundPlan.refreshTask] {
      _ = BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) {
        [weak self] task in
        DispatchQueue.main.async {
          guard let self else {
            task.setTaskCompleted(success: false)
            return
          }
          self.startEngine(inBackground: true)
          self.background?.handle(task: task)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Runs `main()` once. Without a screen it gets the argument
  /// `background`: nothing is drawn and no run starts by itself (D-381).
  func startEngine(inBackground: Bool) {
    guard !engineStarted else { return }
    engineStarted = true
    engine.run(
      withEntrypoint: nil, libraryURI: nil, initialRoute: nil,
      entrypointArgs: inBackground ? ["background"] : [])
    GeneratedPluginRegistrant.register(with: engine)
    // The app's own channels (D-337, D-349, D-374); no plugin.
    voice = VoiceChannel(messenger: engine.binaryMessenger)
    notePlayer = NotePlayerChannel(messenger: engine.binaryMessenger)
    background = BackgroundSync(messenger: engine.binaryMessenger)
  }
}
