//
//  MenuView.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 11/25/25.
//

import SwiftUI
import AVFoundation
import MessageUI
import UIKit


//enum AppAppearance: String, CaseIterable, Identifiable {
//    case system
//    case light
//    case dark
//
//    var id: String { rawValue }
//
//    var title: String {
//        switch self {
//        case .system: return "System"
//        case .light: return "Light"
//        case .dark: return "Dark"
//        }
//    }
//
//    var colorScheme: ColorScheme? {
//        switch self {
//        case .system: return nil
//        case .light: return .light
//        case .dark: return .dark
//        }
//    }
//}

struct MenuView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var speechStore: SpeechSettingsStore
    @EnvironmentObject private var theme: ThemeManager
    @Environment(\.colorScheme) private var systemScheme

//    @AppStorage("pref_showGrid") private var showGrid: Bool = true
//    @AppStorage("pref_saveToPhotos") private var saveToPhotos: Bool = true
//    @AppStorage("pref_haptics") private var haptics: Bool = false
//
//    private let supportEmail = "pouchcell26@gmail.com"
//    private let supportSubject = "PouchCellInspecter – Support / Feedback"
//    private var supportBody: String {
//        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
//        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
//        return """
//        Hi! I need help with:
//
//        App Version: \(version) (\(build))
//        Device: \(UIDevice.current.model)
//        iOS Version: \(UIDevice.current.systemVersion)
//
//        Details:
//        """
//    }

    @State private var showingMailComposer = false
    @State private var showingMailUnavailableAlert = false

    @AppStorage("pref_showGrid") private var showGrid: Bool = true
    @AppStorage("pref_saveToPhotos") private var saveToPhotos: Bool = true

    // ✅ Haptics are OFF by default on first install (opt-in).
    @AppStorage("pref_haptics") private var haptics: Bool = false

    // Support email config
    private let supportEmail = "pouchcell26@gmail.com"
    private let supportSubject = "PouchCellInspecter – Support / Feedback"
    private var supportBody: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return """
        Hi! I need help with:

        App Version: \(version) (\(build))
        Device: \(UIDevice.current.model)
        iOS Version: \(UIDevice.current.systemVersion)

        Details:
        """
    }

    // UI state
//    @State private var showingMailComposer = false
//    @State private var showingMailUnavailableAlert = false

    private var availableVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().sorted { (lhs, rhs) in
            (lhs.language, lhs.name) < (rhs.language, rhs.name)
        }
    }
    

    private var effectiveScheme: ColorScheme? {
        // Key trick: "System" maps to current system scheme (not nil),
        // so it updates immediately without dismissing the sheet.
        theme.appearance == .system ? systemScheme : theme.appearance.colorScheme
    }

    var body: some View {
        NavigationStack {
            List {
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
            
                    Toggle("Enable Haptics", isOn: $haptics)
                    Text("The app can use haptic feedback on the results screen (e.g., a stronger alert for bulging).")
                    
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
                
                Section("Safety") {
                    NavigationLink("Battery inspection disclaimer") {
                        InfoDetailView(
                            title: "Safety Disclaimer",
                            message: "This app provides a visual inspection only and does not replace professional battery testing or safety procedures."
                        )
                    }
                }
                
                // New: camera-ish toggles
                Section("Capture") {
                    //Toggle("Show grid", isOn: $showGrid)
                    //Toggle("High quality capture", isOn: $highQualityCapture)
                    //Toggle("Auto torch", isOn: $autoTorch)
                    Toggle("Save to Photos", isOn: $saveToPhotos)
                    Text("automatically save pictures you've scanned using your iPhone's camera.")
                }
                
                //                    Section("Appearance") {
                //                    Picker("App appearance", selection: $appearance) {
                ////=======
                //                            Section("Capture") {
                //                    //Toggle("Show grid", isOn: $showGrid)
                //                    Toggle("Save to Photos", isOn: $saveToPhotos)
                //                    Text("Automatically save pictures you've scanned using your iPhone's camera.")
                //                }
                
                Section("Appearance") {
                    Picker("App appearance", selection: $theme.appearance) {
                        //>>>>>>> Stashed changes
                        ForEach(AppAppearance.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .onChange(of: theme.appearance) { _, _ in
                        // Keeps UIKit windows in sync immediately
                        theme.apply()
                    }
                }
                
                //                Section("Support") {
                //                    Button {
                //                        openContactUs()
                //                    } label: {
                //                        Label("Contact us", systemImage: "envelope")
                //                    }
                //
                //                    Button {
                //                        openAppSettings()
                //                    } label: {
                //                        Label("Open iOS Settings", systemImage: "gearshape")
                //                    }
                //                }
                
                //<<<<<<< Updated upstream
                Section("Support") {
                    Button {
                        openContactUs()
                    } label: {
                        Label("Contact us", systemImage: "envelope")
                    }
                    
                    Button {
                        openAppSettings()
                    } label: {
                        Label("Open iOS Settings", systemImage: "gearshape")
                    }
                }
                
                // About section WITHOUT version here (so version can be the final row in the whole list)
                Section("About") {
                    NavigationLink("About this app") {
                        InfoDetailView(
                            title: "About",
                            message: "PouchCellInspecter helps with visual inspection and scan-based analysis for pouch cells."
                        )
                    }
                }
                //=======
                //                Section("About") {
                //                    NavigationLink {
                //                        AboutScreen()
                //                    } label: {
                //                        Label("Learn more about Pouch Cell Inspector", systemImage: "book")
                //                    }
                //                }
                
                Section {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text(appVersionString)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            // ✅ Critical change: use effectiveScheme (never nil), so System updates instantly
            .preferredColorScheme(effectiveScheme)
            .sheet(isPresented: $showingMailComposer) {
                MailComposerView(
                    recipients: [supportEmail],
                    subject: supportSubject,
                    body: supportBody
                )
            }
            .alert("Mail not available", isPresented: $showingMailUnavailableAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please set up Mail on this device to send email from within the app.")
            }
        }
    }
    private func openContactUs() {
        if MFMailComposeViewController.canSendMail() {
            showingMailComposer = true
        } else {
            showingMailUnavailableAlert = true
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private var appVersionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
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

// MARK: - In-app Mail Composer

struct MailComposerView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let body: String

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                  didFinishWith result: MFMailComposeResult,
                                  error: Error?) {
            dismiss()
        }
    }
}
                                    

#Preview {
    MenuView()
        .environmentObject(SpeechSettingsStore.shared)
        .environmentObject(ThemeManager.shared)
}

