//
//  ScanHistoryStore.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 4/2/26.
//

import SwiftUI
import UIKit
import Combine
struct ScanHistoryItem: Identifiable, Codable, Equatable {
    let id: UUID
    let resultText: String
    let createdAt: Date
    let imageData: Data?

    init(id: UUID = UUID(), resultText: String, createdAt: Date = Date(), imageData: Data?) {
        self.id = id
        self.resultText = resultText
        self.createdAt = createdAt
        self.imageData = imageData
    }

    var condition: BatteryCondition {
        BatteryCondition(from: resultText)
    }

    var image: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }

    var relativeTimestamp: String {
        createdAt.formatted(.relative(presentation: .named))
    }

    var fullTimestamp: String {
        createdAt.formatted(date: .abbreviated, time: .shortened)
    }
}

@MainActor
final class ScanHistoryStore: ObservableObject {
    static let shared = ScanHistoryStore()

    @Published private(set) var items: [ScanHistoryItem] = []

    private let storageKey = "scanHistoryItems"
    private let maxItems = 50

    private init() {
        load()
    }

    var hasHistory: Bool {
        !items.isEmpty
    }

    func add(resultText: String, image: UIImage?) {
        let compressedImageData = image?.jpegData(compressionQuality: 0.72)

        let newItem = ScanHistoryItem(
            resultText: resultText,
            createdAt: Date(),
            imageData: compressedImageData
        )

        items.insert(newItem, at: 0)

        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }

        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func clearAll() {
        items.removeAll()
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            items = []
            return
        }

        do {
            items = try JSONDecoder().decode([ScanHistoryItem].self, from: data)
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            items = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            assertionFailure("Failed to save scan history: \(error)")
        }
    }
}
