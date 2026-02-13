//
//  SpeechSettingsStore.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 2/10/26.
//

import Foundation
import Combine
final class SpeechSettingsStore: ObservableObject {

    static let shared = SpeechSettingsStore()

    private let key = "speechSettingsData"

    @Published var settings: SpeechSettings {
        didSet { save(settings) }
    }

    private init() {
        self.settings = Self.loadInitial(key: key)
    }

    private func save(_ settings: SpeechSettings) {
        let data = (try? JSONEncoder().encode(settings)) ?? Data()
        UserDefaults.standard.set(data, forKey: key)
    }

    private static func loadInitial(key: String) -> SpeechSettings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(SpeechSettings.self, from: data)
        else {
            return .default
        }
        return decoded
    }
}
