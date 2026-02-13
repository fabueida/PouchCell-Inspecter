//
//  MenuView.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 1/20/26.
//

import SwiftUI
import AVFoundation

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct MenuView: View {

    @Environment(\.dismiss) private var dismiss

    // Shared speech settings used by the whole app
    @EnvironmentObject private var speechStore: SpeechSettingsStore

    @AppStorage("appAppearance") private var appearance: AppAppearance = .system

    private var availableVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().sorted { (lhs, rhs) in
            (lhs.language, lhs.name) < (rhs.language, rhs.name)
        }
    }

    var body: some View {
        NavigationStack {
            List {

                Section("Safety") {
                    NavigationLink("Battery inspection disclaimer") {
                        InfoDetailView(
                            title: "Safety Disclaimer",
                            message: "This app provides a visual inspection only and does not replace professional battery testing or safety procedures."
                        )
                    }
                }

                Section("Accessibility") {
                    Toggle("Speak results after scan", isOn: Binding(
                        get: { speechStore.settings.isEnabled },
                        set: { newValue in
                            var s = speechStore.settings
                            s.isEnabled = newValue
                            speechStore.settings = s

                            if !newValue {
                                SpeechManager.shared.stop()
                            }
                        }
                    ))

                    Text("The app can automatically read out the scan result after analysis.")

                    if speechStore.settings.isEnabled {
                        VStack(alignment: .leading, spacing: 12) {

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Speech rate")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Slider(
                                    value: Binding(
                                        get: { speechStore.settings.rate },
                                        set: { newValue in
                                            var s = speechStore.settings
                                            s.rate = newValue
                                            speechStore.settings = s
                                        }
                                    ),
                                    in: AVSpeechUtteranceMinimumSpeechRate...AVSpeechUtteranceMaximumSpeechRate
                                )
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Pitch")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Slider(
                                    value: Binding(
                                        get: { speechStore.settings.pitch },
                                        set: { newValue in
                                            var s = speechStore.settings
                                            s.pitch = newValue
                                            speechStore.settings = s
                                        }
                                    ),
                                    in: 0.5...2.0
                                )
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Voice")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Picker("Voice", selection: Binding(
                                    get: { speechStore.settings.voiceIdentifier ?? "" },
                                    set: { newValue in
                                        var s = speechStore.settings
                                        s.voiceIdentifier = newValue.isEmpty ? nil : newValue
                                        speechStore.settings = s
                                    }
                                )) {
                                    Text("System default").tag("")

                                    ForEach(availableVoices, id: \.identifier) { voice in
                                        Text("\(voice.name) (\(voice.language))")
                                            .tag(voice.identifier)
                                    }
                                }
                            }

                            Button {
                                let sample = "Scan result reading is enabled."
                                SpeechManager.shared.speak(sample, settings: speechStore.settings)
                            } label: {
                                Label("Test speech", systemImage: "speaker.wave.2.fill")
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }

                Section("Appearance") {
                    Picker("App appearance", selection: $appearance) {
                        ForEach(AppAppearance.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                }

                Section("About") {
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        HStack {
                            Text("App Version")
                            Spacer()
                            Text(version)
                                .foregroundColor(.secondary)
                        }
                    }

                    NavigationLink("Contact & feedback") {
                        InfoDetailView(
                            title: "Contact & Feedback",
                            message: "For feedback or support, please contact our development team."
                        )
                    }
                }
            }
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    // MARK: - On-device reliability helper

    private func speakWithAudioSession(_ text: String, settings: SpeechSettings) {
        // Configure audio session here to avoid "works in simulator, not on phone" issues.
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            // If this fails, still try speaking.
        }

        SpeechManager.shared.speak(text, settings: settings)
    }
}

struct InfoDetailView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle(title)
    }
}

#Preview {
    MenuView()
        .environmentObject(SpeechSettingsStore.shared)
}


