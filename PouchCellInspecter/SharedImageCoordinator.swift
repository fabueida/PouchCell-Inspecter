import Foundation
import UIKit

@MainActor
final class SharedImageCoordinator: ObservableObject {
    @Published private(set) var pendingSharedImageToken: UUID?

    init() {
        if SharedImageStore.hasPendingSharedImage {
            pendingSharedImageToken = UUID()
        }
    }

    func handleIncomingURL(_ url: URL) {
        guard SharedImageStore.matchesSharedImageURL(url) else { return }
        pendingSharedImageToken = UUID()
    }

    func consumePendingSharedImage() -> UIImage? {
        defer { pendingSharedImageToken = nil }

        guard let image = SharedImageStore.loadSharedImage() else {
            SharedImageStore.clearSharedImage()
            return nil
        }

        SharedImageStore.clearSharedImage()
        return image
    }
}
