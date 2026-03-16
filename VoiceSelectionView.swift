//
//  VoiceSelectionView.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 3/16/26.
//

import SwiftUI
import AVFoundation

struct VoiceSelectionView: View {
    @EnvironmentObject private var speechStore: SpeechSettingsStore

    private var groupedVoices: [(language: String, voices: [AVSpeechSynthesisVoice])] {
        let grouped = Dictionary(grouping: AVSpeechSynthesisVoice.speechVoices()) { voice in
            localizedLanguageName(for: voice.language)
        }

        return grouped
            .map { key, value in
                (
                    language: key,
                    voices: value.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                )
            }
            .sorted { $0.language.localizedCaseInsensitiveCompare($1.language) == .orderedAscending }
    }

    var body: some View {
        List {
            Section {
                Button {
                    var s = speechStore.settings
                    s.voiceIdentifier = nil
                    speechStore.settings = s
                } label: {
                    HStack {
                        Text("System Default")
                        Spacer()
                        if speechStore.settings.voiceIdentifier == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .foregroundStyle(.primary)
            } footer: {
                            }

            ForEach(groupedVoices, id: \.language) { group in
                Section(group.language) {
                    ForEach(group.voices, id: \.identifier) { voice in
                        Button {
                            var s = speechStore.settings
                            s.voiceIdentifier = voice.identifier
                            speechStore.settings = s
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(voice.name)

                                    Text(voice.language)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if speechStore.settings.voiceIdentifier == voice.identifier {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
        }
        .navigationTitle("Voice")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func localizedLanguageName(for identifier: String) -> String {
        Locale.current.localizedString(forIdentifier: identifier) ?? identifier
    }
}
