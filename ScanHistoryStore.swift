//
//  ScanHistoryStore.swift
//  PouchCellInspecter
//
//  Created by Firas Abueida on 4/2/26.
//

import SwiftUI
import UIKit
import Combine

enum HistoryRetention: String, CaseIterable, Identifiable {
    case forever
    case ninetyDays
    case thirtyDays
    case off

    var id: String { rawValue }

    var title: String {
        switch self {
        case .forever:
            return "Forever"
        case .ninetyDays:
            return "90 Days"
        case .thirtyDays:
            return "30 Days"
        case .off:
            return "Off"
        }
    }

    var dayLimit: Int? {
        switch self {
        case .forever, .off:
            return nil
        case .ninetyDays:
            return 90
        case .thirtyDays:
            return 30
        }
    }

    static var retentionChoices: [HistoryRetention] {
        [.forever, .ninetyDays, .thirtyDays]
    }
}

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

    static let saveClassificationsLocallyKey = "pref_saveClassificationsLocally"
    static let historyRetentionKey = "pref_historyRetention"

    private let storageKey = "scanHistoryItems"
    private let maxItems = 50

    private init() {
        load()
        applyCurrentSettings()
    }

    var hasHistory: Bool {
        !items.isEmpty
    }

    func add(resultText: String, image: UIImage?) {
        applyCurrentSettings()

        guard isLocalHistorySavingEnabled else { return }

        let compressedImageData = image?.historyThumbnailData(maxDimension: 900, compressionQuality: 0.60)

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

    func applyCurrentSettings() {
        switch historyRetention {
        case .forever, .ninetyDays, .thirtyDays, .off:
            pruneExpiredHistory()
        }
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

    private var isLocalHistorySavingEnabled: Bool {
        isSaveClassificationsLocallyEnabled
    }

    private var isSaveClassificationsLocallyEnabled: Bool {
        UserDefaults.standard.object(forKey: Self.saveClassificationsLocallyKey) as? Bool ?? true
    }

    private var historyRetention: HistoryRetention {
        guard let rawValue = UserDefaults.standard.string(forKey: Self.historyRetentionKey),
              let retention = HistoryRetention(rawValue: rawValue) else {
            return .forever
        }

        return retention
    }

    private func pruneExpiredHistory() {
        guard let dayLimit = historyRetention.dayLimit,
              let cutoffDate = Calendar.current.date(byAdding: .day, value: -dayLimit, to: Date()) else {
            return
        }

        let prunedItems = items.filter { $0.createdAt >= cutoffDate }
        guard prunedItems.count != items.count else { return }

        items = prunedItems
        save()
    }
}

private extension UIImage {
    func historyThumbnailData(maxDimension: CGFloat, compressionQuality: CGFloat) -> Data? {
        let longestSide = max(size.width, size.height)
        let targetImage: UIImage

        if longestSide > maxDimension, longestSide > 0 {
            let scaleRatio = maxDimension / longestSide
            let newSize = CGSize(width: size.width * scaleRatio, height: size.height * scaleRatio)
            let format = UIGraphicsImageRendererFormat.default()
            format.scale = 1
            let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
            targetImage = renderer.image { _ in
                draw(in: CGRect(origin: .zero, size: newSize))
            }
        } else {
            targetImage = self
        }

        return targetImage.jpegData(compressionQuality: compressionQuality)
    }
}
