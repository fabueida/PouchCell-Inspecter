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
