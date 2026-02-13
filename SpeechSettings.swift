//
//  SpeechSettings.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 1/23/26.
//

import AVFoundation

struct SpeechSettings: Codable {
    var isEnabled: Bool
    var rate: Float
    var pitch: Float
    var voiceIdentifier: String?

    var voice: AVSpeechSynthesisVoice? {
        if let id = voiceIdentifier, let v = AVSpeechSynthesisVoice(identifier: id) {
            return v
        }

        // Prefer the user’s current language if available; otherwise fall back to English.
        let localeId = Locale.current.identifier
        return AVSpeechSynthesisVoice(language: localeId)
            ?? AVSpeechSynthesisVoice(language: Locale.current.language.languageCode?.identifier ?? "en-US")
            ?? AVSpeechSynthesisVoice(language: "en-US")
    }

    static let `default` = SpeechSettings(
        isEnabled: false,
        rate: AVSpeechUtteranceDefaultSpeechRate,
        pitch: 1.0,
        voiceIdentifier: nil
    )
}
