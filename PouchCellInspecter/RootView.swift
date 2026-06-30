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
    @State private var shouldShowHomeForSharedImage = SharedImageStore.hasPendingSharedImage
    @EnvironmentObject private var sharedImageCoordinator: SharedImageCoordinator
    @Environment(\.colorScheme) private var systemScheme

    private var effectiveScheme: ColorScheme? {
        // Key trick: never return nil here; use the live system scheme instead.
        theme.appearance == .system ? systemScheme : theme.appearance.colorScheme
    }

    var body: some View {
        Group {
            if hasSeenOnboarding || shouldShowHomeForSharedImage || sharedImageCoordinator.pendingSharedImageToken != nil {
                HomeScreen()
            } else {
                OnboardingContainerView()
            }
        }
        .environmentObject(theme)
        .preferredColorScheme(effectiveScheme)
        .onAppear { theme.apply() } // keeps UIKit windows in sync too
        .onOpenURL { url in
            guard SharedImageStore.matchesSharedImageURL(url) else { return }
            shouldShowHomeForSharedImage = true
            sharedImageCoordinator.handleIncomingURL(url)
        }
        .onChange(of: sharedImageCoordinator.pendingSharedImageToken) { _, token in
            if token != nil {
                shouldShowHomeForSharedImage = true
            }
        }
    }
}
