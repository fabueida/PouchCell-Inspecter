import Foundation
import UIKit
import Combine

struct SharedImageResultPayload: Identifiable {
    let id = UUID()
    let result: String
    let image: UIImage
}

@MainActor
final class SharedImageCoordinator: ObservableObject {
    @Published private(set) var pendingSharedImageToken: UUID?
    @Published private(set) var isProcessingSharedImage = false
    @Published var sharedResultPayload: SharedImageResultPayload?

    private var activeProcessingToken: UUID?

    init() {
        if SharedImageStore.hasPendingSharedImage {
            pendingSharedImageToken = UUID()
        }
    }

    func handleIncomingURL(_ url: URL) {
        guard SharedImageStore.matchesSharedImageURL(url) else { return }
        guard SharedImageStore.hasPendingSharedImage else { return }
        guard !isProcessingSharedImage else { return }

        pendingSharedImageToken = UUID()
    }

    func beginProcessingPendingSharedImage() -> UIImage? {
        guard let token = pendingSharedImageToken else { return nil }
        guard activeProcessingToken != token else { return nil }
        guard !isProcessingSharedImage else { return nil }

        isProcessingSharedImage = true
        activeProcessingToken = token
        pendingSharedImageToken = nil

        guard let image = SharedImageStore.loadSharedImage() else {
            SharedImageStore.clearSharedImage()
            failProcessingSharedImage()
            return nil
        }

        SharedImageStore.clearSharedImage()
        return image
    }

    func finishProcessingSharedImage(result: String, image: UIImage) {
        sharedResultPayload = SharedImageResultPayload(result: result, image: image)
        isProcessingSharedImage = false
        activeProcessingToken = nil
    }

    func failProcessingSharedImage() {
        isProcessingSharedImage = false
        activeProcessingToken = nil
    }
}
