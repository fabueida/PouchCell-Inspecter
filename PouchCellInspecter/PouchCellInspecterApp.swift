import SwiftUI
import TipKit

@main
struct PouchCellInspectorApp: App {

    @StateObject private var speechSettingsStore = SpeechSettingsStore.shared
    @StateObject private var scanHistoryStore = ScanHistoryStore.shared

    init() {
        try? Tips.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(speechSettingsStore)
                .environmentObject(scanHistoryStore)
        }
    }
}
