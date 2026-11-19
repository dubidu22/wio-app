import BackgroundTasks
import Flutter
import Network
import UIKit

/// What iOS keeps for background sync (plan 052, D-376, D-378, D-380), as
/// plain values so RunnerTests can check them.
enum BackgroundPlan {
  /// Processing task for changes and files that wait.
  static let syncTask = "de.wiederinordnung.app.sync"
  /// App-refresh task for the hourly pull.
  static let refreshTask = "de.wiederinordnung.app.refresh"
  static let refreshAfter: TimeInterval = 60 * 60
  /// A refresh task gets about 30 s; a processing task a few minutes.
  static let refreshRunTime: TimeInterval = 25
  static let processingRunTime: TimeInterval = 9 * 60

  enum Step: Equatable {
    case cancelAll
    case refresh
    case processing
  }

  /// The steps for Dart's `schedule` (D-374, D-377).
  static func steps(active: Bool, pending: Bool, files: Bool) -> [Step] {
    guard active else { return [.cancelAll] }
    return pending || files ? [.refresh, .processing] : [.refresh]
  }

  static func refreshRequest(now: Date) -> BGAppRefreshTaskRequest {
    let request = BGAppRefreshTaskRequest(identifier: refreshTask)
    request.earliestBeginDate = now.addingTimeInterval(refreshAfter)
    return request
  }

  static func processingRequest() -> BGProcessingTaskRequest {
    let request = BGProcessingTaskRequest(identifier: syncTask)
    request.requiresNetworkConnectivity = true
    request.requiresExternalPower = false
    return request
  }

  /// Files only on a network that is neither expensive (cellular, a
  /// hotspot) nor constrained (Low Data Mode) (D-378).
  static func filesAllowed(satisfied: Bool, expensive: Bool, constrained: Bool) -> Bool {
    satisfied && !expensive && !constrained
  }

  /// Whether a processing task should be asked for again.
  static func retry(_ answer: String?) -> Bool {
    answer == nil || answer == "retry"
  }
}

/// The app's channel `wio/background` on iOS (D-374): Dart sends
/// `schedule`; task handlers and the grace time after leaving the app ask
/// Dart to `run` and to `stop`. Main thread only.
final class BackgroundSync {
  static let channelName = "wio/background"

  private let channel: FlutterMethodChannel
  private let monitor = NWPathMonitor()
  private var path: NWPath?
  private var grace: UIBackgroundTaskIdentifier = .invalid
  private var runs = 0

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: Self.channelName, binaryMessenger: messenger)
    monitor.pathUpdateHandler = { [weak self] path in
      DispatchQueue.main.async { self?.path = path }
    }
    monitor.start(queue: DispatchQueue(label: "de.wiederinordnung.app.path"))
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.handle(call, result)
    }
  }

  deinit {
    monitor.cancel()
  }

  private func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard call.method == "schedule" else {
      result(FlutterMethodNotImplemented)
      return
    }
    let args = call.arguments as? [String: Any] ?? [:]
    let active = args["active"] as? Bool ?? false
    let pending = args["pending"] as? Bool ?? false
    let files = args["files"] as? Bool ?? false
    apply(BackgroundPlan.steps(active: active, pending: pending, files: files))
    // Just left the app with work waiting: use the time iOS gives a
    // leaving app before it is suspended (D-376).
    if active && (pending || files) && UIApplication.shared.applicationState == .background {
      useGraceTime()
    }
    result(nil)
  }

  private func apply(_ steps: [BackgroundPlan.Step]) {
    for step in steps {
      switch step {
      case .cancelAll:
        BGTaskScheduler.shared.cancelAllTaskRequests()
      case .refresh:
        submit(BackgroundPlan.refreshRequest(now: Date()))
      case .processing:
        submit(BackgroundPlan.processingRequest())
      }
    }
  }

  private func submit(_ request: BGTaskRequest) {
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      // The simulator, or Background App Refresh turned off: the
      // foreground sync stays (R4).
      NSLog("wio: background request not accepted: \(error)")
    }
  }

  private func filesAllowed() -> Bool {
    guard let path else { return false }
    return BackgroundPlan.filesAllowed(
      satisfied: path.status == .satisfied,
      expensive: path.isExpensive,
      constrained: path.isConstrained)
  }

  /// Asks Dart for one run; [done] gets "done", "retry", "skip" or nil.
  func run(until deadline: Date, done: @escaping (String?) -> Void) {
    runs += 1
    let arguments: [String: Any] = [
      "deadlineMs": Int64(deadline.timeIntervalSince1970 * 1000),
      "files": filesAllowed(),
    ]
    channel.invokeMethod("run", arguments: arguments) { [weak self] answer in
      self?.runs -= 1
      done(answer as? String)
    }
  }

  /// The run ends at its next safe point (D-375).
  func stop() {
    channel.invokeMethod("stop", arguments: nil)
  }

  private func useGraceTime() {
    guard grace == .invalid, runs == 0 else { return }
    grace = UIApplication.shared.beginBackgroundTask(withName: "wio sync") { [weak self] in
      // Out of time: the run stops at its next safe point; the task must
      // end now.
      self?.stop()
      self?.endGrace()
    }
    guard grace != .invalid else { return }
    let remaining = UIApplication.shared.backgroundTimeRemaining
    let seconds = remaining.isFinite ? max(0, remaining - 5) : BackgroundPlan.refreshRunTime
    run(until: Date().addingTimeInterval(seconds)) { [weak self] _ in
      self?.endGrace()
    }
  }

  private func endGrace() {
    guard grace != .invalid else { return }
    UIApplication.shared.endBackgroundTask(grace)
    grace = .invalid
  }

  /// A task iOS started (D-376). The refresh is asked for again at once;
  /// a processing task that ends with work left is asked for again.
  func handle(task: BGTask) {
    let refresh = task.identifier == BackgroundPlan.refreshTask
    if refresh {
      submit(BackgroundPlan.refreshRequest(now: Date()))
    }
    task.expirationHandler = { [weak self] in
      DispatchQueue.main.async { self?.stop() }
    }
    let runTime = refresh ? BackgroundPlan.refreshRunTime : BackgroundPlan.processingRunTime
    run(until: Date().addingTimeInterval(runTime)) { [weak self] answer in
      let retry = BackgroundPlan.retry(answer)
      if retry && !refresh {
        self?.submit(BackgroundPlan.processingRequest())
      }
      task.setTaskCompleted(success: !retry)
    }
  }
}
