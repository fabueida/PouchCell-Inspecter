import SwiftUI
import TipKit   // 👈 NEW

@main
struct PouchCellInspectorApp: App {
    
    init() {
        try? Tips.configure()   // Enables TipKit
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

