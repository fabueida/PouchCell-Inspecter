import SwiftUI
import TipKit   // 👈 NEW

@main
struct PouchCellInspectorApp: App {

    // Shared, persisted speech settings (used across the whole app)
    @StateObject private var speechSettingsStore = SpeechSettingsStore.shared
    
    init() {
        try? Tips.configure()   // Enables TipKit
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(speechSettingsStore)
        }
    }
}


