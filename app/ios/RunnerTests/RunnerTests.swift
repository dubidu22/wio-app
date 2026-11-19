import AVFoundation
import Foundation
import Testing

@testable import Runner

/// The iOS guard rules (D-46, D-339, D-340).
struct VoiceGuardTests {
  @Test func noGermanRecognizerMeansRecordOnly() {
    #expect(
      VoiceGuard.decide(recognizerExists: false, supportsOnDevice: false, available: false, speech: .granted)
        == VoiceGuard.noOnDevice)
  }

  @Test func germanOnlyOnTheServerMeansRecordOnly() {
    #expect(
      VoiceGuard.decide(recognizerExists: true, supportsOnDevice: false, available: true, speech: .granted)
        == VoiceGuard.noOnDevice)
  }

  @Test func refusedOrUndecidedSpeechMeansRecordOnlyWithItsHint() {
    for speech in [VoiceGuard.Speech.refused, .undetermined] {
      #expect(
        VoiceGuard.decide(recognizerExists: true, supportsOnDevice: true, available: true, speech: speech)
          == VoiceGuard.speechRefused)
    }
  }

  @Test func unavailableRecognizerMeansRecordOnly() {
    #expect(
      VoiceGuard.decide(recognizerExists: true, supportsOnDevice: true, available: false, speech: .granted)
        == VoiceGuard.noOnDevice)
  }

  @Test func onDeviceGermanPermittedAndAvailableIsReady() {
    #expect(
      VoiceGuard.decide(recognizerExists: true, supportsOnDevice: true, available: true, speech: .granted)
        == VoiceGuard.ready)
  }

  @Test func speechPromptOnlyWhenGermanWorksOnDeviceAndNobodyDecided() {
    #expect(VoiceGuard.needsSpeechPrompt(recognizerExists: true, supportsOnDevice: true, speech: .undetermined))
    #expect(!VoiceGuard.needsSpeechPrompt(recognizerExists: true, supportsOnDevice: false, speech: .undetermined))
    #expect(!VoiceGuard.needsSpeechPrompt(recognizerExists: false, supportsOnDevice: false, speech: .undetermined))
    #expect(!VoiceGuard.needsSpeechPrompt(recognizerExists: true, supportsOnDevice: true, speech: .refused))
    #expect(!VoiceGuard.needsSpeechPrompt(recognizerExists: true, supportsOnDevice: true, speech: .granted))
  }

  @Test func segmentsAreJoinedWithoutEmptyParts() {
    #expect(VoiceGuard.join(["Kiste im Keller", " "], "zwei Lampen ") == "Kiste im Keller zwei Lampen")
    #expect(VoiceGuard.join([], "") == "")
  }
}

/// App data out of iCloud backup (D-347, #19).
struct BackupExclusionTests {
  @Test func applicationSupportIsExcludedAtLaunch() throws {
    // The tests run inside the app, so AppDelegate's launch code has run:
    // read the flag without setting it here (PR 78 review S2).
    let folder = try FileManager.default.url(
      for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    #expect(try BackupExclusion.isExcluded(folder))
    // And the launch code excludes that same folder.
    #expect(try BackupExclusion.excludeAppData().standardizedFileURL == folder.standardizedFileURL)
  }

  @Test func excludingAFolderSetsTheFlag() throws {
    let folder = FileManager.default.temporaryDirectory
      .appendingPathComponent("wio-backup-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: folder) }
    #expect(try !BackupExclusion.isExcluded(folder))
    try BackupExclusion.exclude(folder)
    #expect(try BackupExclusion.isExcluded(folder))
  }
}

/// The M4A file format (D-285, D-338).
struct M4aWriterTests {
  @Test func writesAacLcMono16kHzFromAMicrophoneFormat() throws {
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("wio-writer-\(UUID().uuidString).m4a")
    defer { try? FileManager.default.removeItem(at: url) }
    let input = try #require(AVAudioFormat(standardFormatWithSampleRate: 48_000, channels: 1))
    let writer: M4aWriter
    do {
      writer = try M4aWriter(url: url, input: input)
    } catch {
      Issue.record("M4aWriter init threw: \(error)")
      throw error
    }
    // One second of a quiet 440 Hz tone in 4800-frame blocks, as a tap does.
    for block in 0..<10 {
      let buffer = try #require(AVAudioPCMBuffer(pcmFormat: input, frameCapacity: 4_800))
      buffer.frameLength = 4_800
      let samples = try #require(buffer.floatChannelData?[0])
      for i in 0..<4_800 {
        let t = Double(block * 4_800 + i) / 48_000
        samples[i] = Float(0.2 * sin(2 * Double.pi * 440 * t))
      }
      writer.write(buffer)
    }
    #expect(writer.error == nil, "writer error: \(writer.error ?? "")")
    writer.close()
    // The converter holds back a few frames until close drains it; the
    // length counts what reached the file (PR 78 review round 1).
    #expect((950...1_010).contains(writer.millis), "millis: \(writer.millis)")
    #expect(writer.error == nil, "writer error after close: \(writer.error ?? "")")

    let file = try AVAudioFile(forReading: url)
    let format = file.fileFormat.streamDescription.pointee
    #expect(format.mFormatID == kAudioFormatMPEG4AAC, "format id: \(format.mFormatID)")
    #expect(file.fileFormat.sampleRate == 16_000, "rate: \(file.fileFormat.sampleRate)")
    #expect(file.fileFormat.channelCount == 1, "channels: \(file.fileFormat.channelCount)")
    // AAC works in 1024-frame packets with encoder priming: allow two
    // packets either way around one second.
    #expect((14_000...18_100).contains(file.length), "frames on disk: \(file.length)")
    #expect(M4aWriter.fileSettings[AVEncoderBitRateKey] as? Int == 64_000)
  }

  /// Whether Apple's AAC-LC encoder offers 64 kbit/s at 16 kHz mono
  /// (D-285); the message lists what it offers.
  @Test func encoderOffers64kbitAt16kHzMono() throws {
    let pcm = try #require(AVAudioFormat(standardFormatWithSampleRate: 16_000, channels: 1))
    var aac = AudioStreamBasicDescription(
      mSampleRate: 16_000, mFormatID: kAudioFormatMPEG4AAC, mFormatFlags: 0,
      mBytesPerPacket: 0, mFramesPerPacket: 1024, mBytesPerFrame: 0,
      mChannelsPerFrame: 1, mBitsPerChannel: 0, mReserved: 0)
    let out = try #require(AVAudioFormat(streamDescription: &aac))
    let converter = try #require(AVAudioConverter(from: pcm, to: out))
    let offered = (converter.applicableEncodeBitRates ?? []).map(\.intValue)
    #expect(offered.contains(64_000), "AAC-LC 16 kHz mono offers: \(offered)")
  }
}
