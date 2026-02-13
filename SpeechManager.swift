//
//  SpeechManager.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 1/23/26.
//

import Foundation
import AVFoundation

@MainActor
final class SpeechManager: NSObject, AVSpeechSynthesizerDelegate {

    static let shared = SpeechManager()

    private let synthesizer = AVSpeechSynthesizer()

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// Main entry point: speak arbitrary text using provided settings.
    /// (This is PUBLIC so screens like DetectionResultScreen can call it.)
    func speak(_ text: String, settings: SpeechSettings) {
        guard settings.isEnabled else { return }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        configureAudioSessionForSpeech()

        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.rate = settings.rate
        utterance.pitchMultiplier = settings.pitch
        utterance.voice = settings.voice

        // Interrupt any previous speech
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    /// Convenience for result reading (optional)
    func speakResult(condition: String, explanation: String, settings: SpeechSettings) {
        speak("Battery is \(condition). \(explanation)", settings: settings)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        deactivateAudioSession()
    }

    // MARK: - Audio session (reliability on device)

    private func configureAudioSessionForSpeech() {
        let session = AVAudioSession.sharedInstance()
        do {
            // playback + spokenAudio = consistent speech output on iPhone
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true, options: [])
        } catch {
            // Even if session fails, speech may still work; don’t crash.
        }
    }

    private func deactivateAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setActive(false, options: [.notifyOthersOnDeactivation])
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        deactivateAudioSession()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        deactivateAudioSession()
    }
}
