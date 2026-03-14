//
//  RootView.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 12/7/25.
//

import SwiftUI

struct RootView: View {

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @StateObject private var theme = ThemeManager.shared
    @Environment(\.colorScheme) private var systemScheme

    private var effectiveScheme: ColorScheme? {
        // Key trick: never return nil here; use the live system scheme instead.
        theme.appearance == .system ? systemScheme : theme.appearance.colorScheme
    }

    var body: some View {
        Group {
            if hasSeenOnboarding {
                HomeScreen()
            } else {
                OnboardingContainerView()
            }
        }
        .environmentObject(theme)
        .preferredColorScheme(effectiveScheme)
        .onAppear { theme.apply() } // keeps UIKit windows in sync too
    }
}


