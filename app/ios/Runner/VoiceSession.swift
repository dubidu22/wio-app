import AVFoundation
import Speech

/// One voice note on iOS (D-338): one `AVAudioEngine` input tap feeds the
/// M4A writer and, when the guard allowed it, an on-device recognizer
/// (D-339). Recognition runs in segments while recording goes on (D-341);
/// a recognizer error never stops the recording (D-62).
///
/// Called on the main thread; the tap runs on the audio thread and only
/// touches `writer` and `request` under `lock`.
final class VoiceSession {
  struct Outcome {
    let millis: Int
    let transcript: String
    let error: String?
  }

  /// Longest wait for the last words after Stopp (D-289, D-341).
  static let finalWait: TimeInterval = 5
  /// Recognizer errors in a row without text before transcription stops.
  static let maxEmptyErrors = 3

  private let engine = AVAudioEngine()
  private let url: URL
  private let recognizer: SFSpeechRecognizer?
  private let onPartial: (String) -> Void

  private let lock = NSLock()
  private var writer: M4aWriter?
  private var request: SFSpeechAudioBufferRecognitionRequest?
  private var capturing = false

  private var task: SFSpeechRecognitionTask?
  private var segments: [String] = []
  private var current = ""
  private var emptyErrors = 0
  private var recognizerError: String?
  private var finishing: ((Outcome) -> Void)?
  private var finalMillis = 0
  private var writerError: String?

  /// [recognizer] is nil when the guard said record only.
  init(path: String, recognizer: SFSpeechRecognizer?, onPartial: @escaping (String) -> Void) {
    self.url = URL(fileURLWithPath: path)
    self.recognizer = recognizer
    self.onPartial = onPartial
  }

  /// Opens the audio session, the file and the microphone at once (D-288).
  func start() throws {
    let audio = AVAudioSession.sharedInstance()
    try audio.setCategory(.record, mode: .default, options: [])
    try audio.setActive(true)
    do {
      let input = engine.inputNode
      let format = input.outputFormat(forBus: 0)
      guard format.sampleRate > 0, format.channelCount > 0 else {
        throw M4aWriter.Failure(description: "no microphone input")
      }
      try? FileManager.default.removeItem(at: url)
      let writer = try M4aWriter(url: url, input: format)
      lock.lock()
      self.writer = writer
      capturing = true
      lock.unlock()
      if recognizer != nil { startRecognition() }
      input.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] buffer, _ in
        self?.feed(buffer)
      }
      engine.prepare()
      try engine.start()
    } catch {
      endCapture()
      task?.cancel()
      task = nil
      try? FileManager.default.removeItem(at: url)
      throw error
    }
  }

  /// Whether the microphone still delivers (false after the system stopped
  /// the engine, D-343).
  var isRunning: Bool { engine.isRunning }

  /// Audio thread.
  private func feed(_ buffer: AVAudioPCMBuffer) {
    lock.lock()
    defer { lock.unlock() }
    guard capturing else { return }
    writer?.write(buffer)
    request?.append(buffer)
  }

  private func startRecognition() {
    guard let recognizer = recognizer else { return }
    let next = SFSpeechAudioBufferRecognitionRequest()
    // Never leaves the phone (D-46, D-339).
    next.requiresOnDeviceRecognition = true
    next.shouldReportPartialResults = true
    if #available(iOS 16.0, *) { next.addsPunctuation = true }
    lock.lock()
    request = next
    lock.unlock()
    current = ""
    task = recognizer.recognitionTask(with: next) { [weak self] result, error in
      DispatchQueue.main.async {
        self?.onResult(next, result, error)
      }
    }
  }

  private func onResult(
    _ from: SFSpeechAudioBufferRecognitionRequest,
    _ result: SFSpeechRecognitionResult?,
    _ error: Error?
  ) {
    lock.lock()
    let active = request === from
    let stillCapturing = capturing
    lock.unlock()
    guard active else { return }
    if let result = result {
      current = result.bestTranscription.formattedString
      if !current.isEmpty { emptyErrors = 0 }
      if stillCapturing { onPartial(VoiceGuard.join(segments, current)) }
    }
    let done = (result?.isFinal ?? false) || error != nil
    guard done else { return }
    if let error = error, current.isEmpty {
      emptyErrors += 1
      if recognizerError == nil { recognizerError = error.localizedDescription }
    }
    if !current.isEmpty { segments.append(current) }
    current = ""
    task = nil
    lock.lock()
    request = nil
    lock.unlock()
    if stillCapturing && emptyErrors < VoiceSession.maxEmptyErrors {
      startRecognition()
    } else {
      finish()
    }
  }

  /// Ends recording; [done] gets the length and the text, at most 5 s
  /// later (D-289).
  func stop(_ done: @escaping (Outcome) -> Void) {
    endCapture()
    lock.lock()
    let open = request
    lock.unlock()
    guard task != nil, open != nil else {
      finishing = done
      finish()
      return
    }
    finishing = done
    open?.endAudio()
    DispatchQueue.main.asyncAfter(deadline: .now() + VoiceSession.finalWait) { [weak self] in
      self?.finish()
    }
  }

  /// Ends without a result and deletes the file.
  func cancel() {
    finishing = nil
    endCapture()
    task?.cancel()
    task = nil
    lock.lock()
    request = nil
    lock.unlock()
    try? FileManager.default.removeItem(at: url)
  }

  private func endCapture() {
    if engine.isRunning { engine.stop() }
    engine.inputNode.removeTap(onBus: 0)
    lock.lock()
    let wasCapturing = capturing
    capturing = false
    let open = writer
    writer = nil
    lock.unlock()
    if let open = open {
      open.close()
      finalMillis = open.millis
      writerError = open.error
    }
    if wasCapturing {
      try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
  }

  private func finish() {
    guard let done = finishing else { return }
    finishing = nil
    task?.cancel()
    task = nil
    lock.lock()
    request = nil
    lock.unlock()
    if !current.isEmpty {
      segments.append(current)
      current = ""
    }
    let transcript = VoiceGuard.join(segments, "")
    done(Outcome(
      millis: finalMillis,
      transcript: transcript,
      error: writerError ?? (transcript.isEmpty ? recognizerError : nil)
    ))
  }
}
