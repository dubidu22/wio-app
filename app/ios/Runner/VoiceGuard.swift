import Foundation

/// The rules of the on-device guard on iOS (D-46, D-339), apart from the
/// Speech framework so they have tests. A transcript is made only with a
/// German recognizer that works on the device, is available now and may be
/// used; every request also sets `requiresOnDeviceRecognition` (D-339), so
/// this guard decides only which hint the worker sees.
enum VoiceGuard {
  static let ready = "ready"
  static let noOnDevice = "noOnDevice"
  static let speechRefused = "speechRefused"

  /// The speech recognition permission, reduced to what the guard needs.
  enum Speech {
    case undetermined
    case granted
    case refused
  }

  /// The answer for one recording.
  static func decide(
    recognizerExists: Bool,
    supportsOnDevice: Bool,
    available: Bool,
    speech: Speech
  ) -> String {
    if !recognizerExists || !supportsOnDevice { return noOnDevice }
    if speech != .granted { return speechRefused }
    if !available { return noOnDevice }
    return ready
  }

  /// Whether the speech prompt still has to be shown (D-340): only when
  /// German can be recognized on this device and nobody decided yet.
  static func needsSpeechPrompt(
    recognizerExists: Bool,
    supportsOnDevice: Bool,
    speech: Speech
  ) -> Bool {
    recognizerExists && supportsOnDevice && speech == .undetermined
  }

  /// Segments heard so far plus the current partial text (D-62, D-341).
  static func join(_ segments: [String], _ current: String) -> String {
    (segments + [current])
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
      .joined(separator: " ")
  }
}
