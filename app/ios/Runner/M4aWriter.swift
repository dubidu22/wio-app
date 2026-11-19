import AVFoundation

/// Writes microphone buffers as AAC-LC in M4A, 16 kHz mono, 64 kbit/s
/// (D-285, D-338). Input buffers come in the microphone's own format and
/// are converted here. Not thread-safe: the caller serialises writes.
final class M4aWriter {
  static let sampleRate: Double = 16_000
  static let bitRate = 64_000

  /// Settings of the file on disk.
  static var fileSettings: [String: Any] {
    [
      AVFormatIDKey: kAudioFormatMPEG4AAC,
      AVSampleRateKey: sampleRate,
      AVNumberOfChannelsKey: 1,
      AVEncoderBitRateKey: bitRate,
    ]
  }

  struct Failure: Error, CustomStringConvertible {
    let description: String
  }

  private var file: AVAudioFile?
  private let converter: AVAudioConverter
  private let output: AVAudioFormat

  /// Frames written at 16 kHz.
  private(set) var frames: AVAudioFramePosition = 0

  /// The first write error, for `stop`'s `error`.
  private(set) var error: String?

  init(url: URL, input: AVAudioFormat) throws {
    let file = try AVAudioFile(
      forWriting: url,
      settings: M4aWriter.fileSettings,
      commonFormat: .pcmFormatFloat32,
      interleaved: false
    )
    guard let converter = AVAudioConverter(from: input, to: file.processingFormat) else {
      throw Failure(description: "no converter from \(input)")
    }
    self.file = file
    self.converter = converter
    self.output = file.processingFormat
  }

  /// Milliseconds of audio written.
  var millis: Int { Int(frames * 1000 / AVAudioFramePosition(M4aWriter.sampleRate)) }

  func write(_ buffer: AVAudioPCMBuffer) {
    guard let file = file, buffer.frameLength > 0 else { return }
    let ratio = output.sampleRate / buffer.format.sampleRate
    let capacity = AVAudioFrameCount((Double(buffer.frameLength) * ratio).rounded(.up)) + 32
    guard let converted = AVAudioPCMBuffer(pcmFormat: output, frameCapacity: capacity) else {
      remember("no output buffer")
      return
    }
    var given = false
    var failure: NSError?
    let status = converter.convert(to: converted, error: &failure) { _, inputStatus in
      if given {
        inputStatus.pointee = .noDataNow
        return nil
      }
      given = true
      inputStatus.pointee = .haveData
      return buffer
    }
    if status == .error {
      remember(failure?.localizedDescription ?? "convert failed")
      return
    }
    guard converted.frameLength > 0 else { return }
    do {
      try file.write(from: converted)
      frames += AVAudioFramePosition(converted.frameLength)
    } catch {
      remember(error.localizedDescription)
    }
  }

  /// Finishes the file; later writes do nothing.
  func close() {
    // AVAudioFile finishes the M4A when it is released; this writer holds
    // the only reference.
    file = nil
  }

  private func remember(_ message: String) {
    if error == nil { error = message }
  }
}
