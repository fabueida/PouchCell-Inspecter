import UIKit
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {
    private let supportedTypeIdentifiers = [
        UTType.heic.identifier,
        UTType.jpeg.identifier,
        UTType.png.identifier,
        UTType.image.identifier,
        UTType.fileURL.identifier
    ]

    private var hasStartedProcessing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        view.addSubview(indicator)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !hasStartedProcessing else { return }
        hasStartedProcessing = true

        Task {
            await processSharedImage()
        }
    }

    @MainActor
    private func processSharedImage() async {
        do {
            let image = try await loadSharedImage()
            try saveSharedImage(image)
            openMainApp()
        } catch {
            extensionContext?.cancelRequest(withError: error)
        }
    }

    private func loadSharedImage() async throws -> UIImage {
        let providers = extensionContext?.inputItems
            .compactMap { $0 as? NSExtensionItem }
            .flatMap { $0.attachments ?? [] } ?? []

        guard !providers.isEmpty else {
            throw ShareExtensionError.noAttachments
        }

        for provider in providers {
            if provider.canLoadObject(ofClass: UIImage.self), let image = try await loadObjectImage(from: provider) {
                return image
            }

            for typeIdentifier in supportedTypeIdentifiers where provider.hasItemConformingToTypeIdentifier(typeIdentifier) {
                if let image = try await loadDataImage(from: provider, typeIdentifier: typeIdentifier) {
                    return image
                }

                if let image = try await loadFileImage(from: provider, typeIdentifier: typeIdentifier) {
                    return image
                }

                if let image = try await loadURLImage(from: provider, typeIdentifier: typeIdentifier) {
                    return image
                }
            }
        }

        throw ShareExtensionError.unsupportedImage
    }

    private func loadObjectImage(from provider: NSItemProvider) async throws -> UIImage? {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadObject(ofClass: UIImage.self) { object, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: object as? UIImage)
            }
        }
    }

    private func loadDataImage(from provider: NSItemProvider, typeIdentifier: String) async throws -> UIImage? {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadDataRepresentation(forTypeIdentifier: typeIdentifier) { data, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let data else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: UIImage(data: data))
            }
        }
    }

    private func loadFileImage(from provider: NSItemProvider, typeIdentifier: String) async throws -> UIImage? {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let url else {
                    continuation.resume(returning: nil)
                    return
                }

                if let image = UIImage(contentsOfFile: url.path) {
                    continuation.resume(returning: image)
                    return
                }

                guard let data = try? Data(contentsOf: url) else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: UIImage(data: data))
            }
        }
    }

    private func loadURLImage(from provider: NSItemProvider, typeIdentifier: String) async throws -> UIImage? {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { item, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let url: URL?
                if let itemURL = item as? URL {
                    url = itemURL
                } else if let data = item as? Data {
                    url = URL(dataRepresentation: data, relativeTo: nil)
                } else {
                    url = nil
                }

                guard let url, let data = try? Data(contentsOf: url) else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: UIImage(data: data))
            }
        }
    }

    private func saveSharedImage(_ image: UIImage) throws {
        guard let jpegData = image.jpegData(compressionQuality: 0.95) else {
            throw ShareExtensionError.encodingFailed
        }

        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: ShareExtensionConfiguration.appGroupIdentifier
        ) else {
            throw ShareExtensionError.missingAppGroupContainer
        }

        let imageURL = containerURL.appendingPathComponent(ShareExtensionConfiguration.sharedFilename)
        if FileManager.default.fileExists(atPath: imageURL.path) {
            try? FileManager.default.removeItem(at: imageURL)
        }

        try jpegData.write(to: imageURL, options: .atomic)

        guard let defaults = UserDefaults(suiteName: ShareExtensionConfiguration.appGroupIdentifier) else {
            throw ShareExtensionError.missingAppGroupDefaults
        }

        defaults.set(true, forKey: ShareExtensionConfiguration.pendingSharedImageKey)
    }

    private func openMainApp() {
        requestContainingAppLaunch(with: ShareExtensionConfiguration.incomingURL)
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    @discardableResult
    private func requestContainingAppLaunch(with url: URL) -> Bool {
        let selector = NSSelectorFromString("openURL:")
        let startingResponders: [UIResponder?] = [self, view, view.window]

        for startingResponder in startingResponders {
            var responder = startingResponder

            while let currentResponder = responder {
                if currentResponder.responds(to: selector) {
                    currentResponder.perform(selector, with: url)
                    return true
                }

                responder = currentResponder.next
            }
        }

        return false
    }
}

private enum ShareExtensionConfiguration {
    static let appGroupIdentifier = "group.com.yourteam.PouchCellInspector"
    static let sharedFilename = "shared-image.jpg"
    static let pendingSharedImageKey = "hasPendingSharedImage"
    static let incomingURL = URL(string: "pouchcellinspector://shared-image")!
}

private enum ShareExtensionError: LocalizedError {
    case noAttachments
    case unsupportedImage
    case encodingFailed
    case missingAppGroupContainer
    case missingAppGroupDefaults

    var errorDescription: String? {
        switch self {
        case .noAttachments:
            return "No shared image was found."
        case .unsupportedImage:
            return "The shared item could not be loaded as an image."
        case .encodingFailed:
            return "The shared image could not be prepared for transfer."
        case .missingAppGroupContainer:
            return "The shared container is unavailable."
        case .missingAppGroupDefaults:
            return "The shared defaults container is unavailable."
        }
    }
}
