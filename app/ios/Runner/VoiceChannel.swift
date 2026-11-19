import AVFoundation
import Flutter
import Speech
import UIKit

/// Method channel "wio/voice" on iOS (D-337): the same calls and answers as
/// the Android `VoiceChannel`, so the Dart side is shared. Microphone and
/// speech permission (D-340), one voice note at a time (D-338), the
/// on-device guard for German (D-46, D-339), the screen kept on (D-345) and
/// interruptions that end and save the note (D-343).
///
/// Every recognition request sets `requiresOnDeviceRecognition`; there is
/// no code path to Apple's server recognizer.
final class VoiceChannel {
  static let name = "wio/voice"
  static let language = "de-DE"

  private let channel: FlutterMethodChannel
  private var session: VoiceSession?
  private var observers: [NSObjectProtocol] = []

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: VoiceChannel.name, binaryMessenger: messenger)
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
    case "permission":
      result(microphone() == .granted && !needsSpeechPrompt() ? "granted" : "refused")
    case "requestPermission":
      requestPermission(result)
    case "start":
      guard let args = call.arguments as? [String: Any], let path = args["path"] as? String else {
        result(FlutterError(code: "failed", message: "no path", details: nil))
        return
      }
      start(path, result)
    case "stop":
      stop(result)
    case "cancel":
      cancel()
      result(nil)
    case "downloadGerman":
      // iOS has no API to load a recognizer language (D-339).
      result(false)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: Permission (D-340)

  private enum Microphone {
    case undetermined
    case granted
    case refused
  }

  private func microphone() -> Microphone {
    if #available(iOS 17.0, *) {
      switch AVAudioApplication.shared.recordPermission {
      case .granted: return .granted
      case .denied: return .refused
      default: return .undetermined
      }
    }
    switch AVAudioSession.sharedInstance().recordPermission {
    case .granted: return .granted
    case .denied: return .refused
    default: return .undetermined
    }
  }

  private func requestMicrophone(_ done: @escaping (Bool) -> Void) {
    if #available(iOS 17.0, *) {
      AVAudioApplication.requestRecordPermission { granted in
        DispatchQueue.main.async { done(granted) }
      }
      return
    }
    AVAudioSession.sharedInstance().requestRecordPermission { granted in
      DispatchQueue.main.async { done(granted) }
    }
  }

  private static func speech() -> VoiceGuard.Speech {
    switch SFSpeechRecognizer.authorizationStatus() {
    case .authorized: return .granted
    case .notDetermined: return .undetermined
    default: return .refused
    }
  }

  private func recognizer() -> SFSpeechRecognizer? {
    SFSpeechRecognizer(locale: Locale(identifier: VoiceChannel.language))
  }

  private func needsSpeechPrompt() -> Bool {
    let german = recognizer()
    return VoiceGuard.needsSpeechPrompt(
      recognizerExists: german != nil,
      supportsOnDevice: german?.supportsOnDeviceRecognition ?? false,
      speech: VoiceChannel.speech()
    )
  }

  /// Microphone first, then speech recognition when it is still open; the
  /// answer is the microphone's (a speech refusal only removes the text).
  private func requestPermission(_ result: @escaping FlutterResult) {
    requestMicrophone { [weak self] granted in
      guard let self = self, granted, self.needsSpeechPrompt() else {
        result(granted ? "granted" : "refused")
        return
      }
      SFSpeechRecognizer.requestAuthorization { _ in
        DispatchQueue.main.async { result("granted") }
      }
    }
  }

  // MARK: Recording

  private func start(_ path: String, _ result: @escaping FlutterResult) {
    if session != nil {
      result(FlutterError(code: "busy", message: "a voice note is already recording", details: nil))
      return
    }
    if microphone() != .granted {
      result(FlutterError(code: "refused", message: "microphone not granted", details: nil))
      return
    }
    let german = recognizer()
    let status = VoiceGuard.decide(
      recognizerExists: german != nil,
      supportsOnDevice: german?.supportsOnDeviceRecognition ?? false,
      available: german?.isAvailable ?? false,
      speech: VoiceChannel.speech()
    )
    let next = VoiceSession(
      path: path,
      recognizer: status == VoiceGuard.ready ? german : nil,
      onPartial: { [weak self] text in
        self?.channel.invokeMethod("onPartial", arguments: text)
      }
    )
    do {
      try next.start()
    } catch {
      result(FlutterError(code: "busy", message: "\(error)", details: nil))
      return
    }
    session = next
    keepScreenOn(true)
    result(nil)
    DispatchQueue.main.async { [weak self] in
      guard let self = self, self.session === next else { return }
      self.channel.invokeMethod("onTranscription", arguments: status)
    }
  }

  private func stop(_ result: @escaping FlutterResult) {
    guard let current = session else {
      result(FlutterError(code: "notStarted", message: "no voice note is recording", details: nil))
      return
    }
    session = nil
    keepScreenOn(false)
    current.stop { outcome in
      var answer: [String: Any] = [
        "millis": outcome.millis,
        "transcript": outcome.transcript,
      ]
      if let error = outcome.error { answer["error"] = error }
      result(answer)
    }
  }

  private func cancel() {
    session?.cancel()
    session = nil
    keepScreenOn(false)
  }

  /// Screen stays on while recording (D-345).
  private func keepScreenOn(_ on: Bool) {
    UIApplication.shared.isIdleTimerDisabled = on
  }

  // MARK: Interruptions (D-343)

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
    observers.append(center.addObserver(
      forName: AVAudioSession.mediaServicesWereResetNotification, object: audio, queue: .main
    ) { [weak self] _ in
      self?.interrupted()
    })
    observers.append(center.addObserver(
      forName: .AVAudioEngineConfigurationChange, object: nil, queue: .main
    ) { [weak self] _ in
      // The engine stops itself when the hardware changes; a notice while
      // it still runs (for example during start) changes nothing.
      guard let current = self?.session, !current.isRunning else { return }
      self?.interrupted()
    })
  }

  /// Dart answers with `stop`, which saves what was recorded.
  private func interrupted() {
    guard session != nil else { return }
    channel.invokeMethod("onInterrupted", arguments: nil)
  }

  /// When the engine goes away.
  func dispose() {
    cancel()
  }
}
