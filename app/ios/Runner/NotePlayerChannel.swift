import AVFoundation
import Flutter

/// Method channel "wio/player" on iOS (D-349): plays one note's recording
/// at a time from a local file, with the same calls and events as Android
/// (D-300, D-301): `play({path})`, `stop`; events `onPosition(millis)`
/// every 250 ms, `onEnded` and `onError`. No network, no permission. Plays
/// with the silent switch on (D-342) and stops on interruptions (D-343).
final class NotePlayerChannel: NSObject, AVAudioPlayerDelegate {
  static let name = "wio/player"
  static let tick: TimeInterval = 0.25

  private let channel: FlutterMethodChannel
  private var player: AVAudioPlayer?
  private var timer: Timer?
  private var observers: [NSObjectProtocol] = []

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: NotePlayerChannel.name, binaryMessenger: messenger)
    super.init()
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.handle(call, result)
    }
    observeInterruptions()
  }

  deinit {
    for observer in observers { NotificationCenter.default.removeObserver(observer) }
  }

  private func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    switch call.method {
    case "play":
      guard let args = call.arguments as? [String: Any], let path = args["path"] as? String else {
        result(FlutterError(code: "failed", message: "no path", details: nil))
        return
      }
      do {
        try play(path)
        result(nil)
      } catch {
        release()
        result(FlutterError(code: "failed", message: "\(error)", details: nil))
      }
    case "stop":
      release()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func play(_ path: String) throws {
    release()
    let audio = AVAudioSession.sharedInstance()
    try audio.setCategory(.playback, mode: .spokenAudio, options: [])
    try audio.setActive(true)
    let next = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
    next.delegate = self
    player = next
    guard next.play() else {
      throw NSError(domain: "wio.player", code: 1, userInfo: [NSLocalizedDescriptionKey: "play failed"])
    }
    let ticker = Timer(timeInterval: NotePlayerChannel.tick, repeats: true) { [weak self] _ in
      guard let self = self, let current = self.player else { return }
      self.channel.invokeMethod("onPosition", arguments: Int(current.currentTime * 1000))
    }
    RunLoop.main.add(ticker, forMode: .common)
    timer = ticker
  }

  private func release() {
    timer?.invalidate()
    timer = nil
    guard let current = player else { return }
    player = nil
    current.delegate = nil
    current.stop()
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
  }

  func audioPlayerDidFinishPlaying(_ finished: AVAudioPlayer, successfully flag: Bool) {
    guard finished === player else { return }
    release()
    channel.invokeMethod(flag ? "onEnded" : "onError", arguments: nil)
  }

  func audioPlayerDecodeErrorDidOccur(_ failed: AVAudioPlayer, error: Error?) {
    guard failed === player else { return }
    release()
    channel.invokeMethod("onError", arguments: nil)
  }

  private func observeInterruptions() {
    let center = NotificationCenter.default
    let audio = AVAudioSession.sharedInstance()
    observers.append(center.addObserver(
      forName: AVAudioSession.interruptionNotification, object: audio, queue: .main
    ) { [weak self] note in
      let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
      if raw.flatMap(AVAudioSession.InterruptionType.init(rawValue:)) == .began { self?.interrupted() }
    })
    observers.append(center.addObserver(
      forName: AVAudioSession.routeChangeNotification, object: audio, queue: .main
    ) { [weak self] note in
      let raw = note.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt
      if raw.flatMap(AVAudioSession.RouteChangeReason.init(rawValue:)) == .oldDeviceUnavailable {
        self?.interrupted()
      }
    })
  }

  private func interrupted() {
    guard player != nil else { return }
    release()
    channel.invokeMethod("onEnded", arguments: nil)
  }

  /// When the engine goes away.
  func dispose() {
    release()
  }
}
