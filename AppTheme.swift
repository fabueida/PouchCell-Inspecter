//
//  AppTheme.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 11/26/25.
//

import SwiftUI
import UIKit
import Combine

// MARK: - App Color Palette (used by HomeScreen, etc.)

enum AppTheme {
    static let accent: Color = Color.accentColor
    static let background: Color = Color(.systemBackground)
}

// MARK: - Appearance (Light / Dark / System)

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var uiStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    private static let storageKey = "appAppearance"

    @Published var appearance: AppAppearance {
        didSet {
            UserDefaults.standard.set(appearance.rawValue, forKey: Self.storageKey)
            apply()
        }
    }

    private init() {
        let raw = UserDefaults.standard.string(forKey: Self.storageKey) ?? AppAppearance.system.rawValue
        self.appearance = AppAppearance(rawValue: raw) ?? .system
        apply()
    }

    func apply() {
        let style = appearance.uiStyle
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}


