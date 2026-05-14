import Foundation
import UIKit

enum SharedImageStore {
    static let appGroupID = "group.com.yourteam.PouchCellInspector"
    static let sharedImageFileName = "shared-image.jpg"
    static let pendingSharedImageKey = "hasPendingSharedImage"
    static let incomingURL = URL(string: "pouchcellinspector://shared-image")!

    static func saveSharedImage(_ image: UIImage) throws {
        guard let imageData = image.jpegData(compressionQuality: 0.95) else {
            throw SharedImageStoreError.encodingFailed
        }

        guard let imageURL = sharedImageURL else {
            throw SharedImageStoreError.missingAppGroupContainer
        }

        if FileManager.default.fileExists(atPath: imageURL.path) {
            try? FileManager.default.removeItem(at: imageURL)
        }

        try imageData.write(to: imageURL, options: .atomic)
        hasPendingSharedImage = true
    }

    static func loadSharedImage() -> UIImage? {
        guard hasPendingSharedImage else { return nil }
        guard let imageURL = sharedImageURL else { return nil }
        guard let data = try? Data(contentsOf: imageURL) else { return nil }
        return UIImage(data: data)
    }

    static func clearSharedImage() {
        if let imageURL = sharedImageURL {
            try? FileManager.default.removeItem(at: imageURL)
        }

        hasPendingSharedImage = false
    }

    static var hasPendingSharedImage: Bool {
        get { sharedDefaults?.bool(forKey: pendingSharedImageKey) ?? false }
        set { sharedDefaults?.set(newValue, forKey: pendingSharedImageKey) }
    }

    static func matchesSharedImageURL(_ url: URL) -> Bool {
        url.scheme == incomingURL.scheme && url.host == incomingURL.host
    }

    private static var sharedImageURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent(sharedImageFileName)
    }

    private static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
}

enum SharedImageStoreError: LocalizedError {
    case encodingFailed
    case missingAppGroupContainer

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "The shared image could not be encoded."
        case .missingAppGroupContainer:
            return "The shared App Group container is unavailable."
        }
    }
}
