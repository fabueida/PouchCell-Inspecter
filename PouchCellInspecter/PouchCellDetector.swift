import CoreML
import Vision
import UIKit

struct PouchCellDetectionResult {
    let observations: [VNRecognizedObjectObservation]
    let confidenceThreshold: Float

    var detectedObservations: [VNRecognizedObjectObservation] {
        observations.filter { observation in
            observation.confidence >= confidenceThreshold &&
            (observation.labels.first?.identifier == "pouch_cell" || observation.labels.isEmpty)
        }
    }

    var hasPouchCell: Bool { !detectedObservations.isEmpty }
    var bestObservation: VNRecognizedObjectObservation? {
        detectedObservations.max(by: { $0.confidence < $1.confidence })
    }
    var bestConfidence: Float { bestObservation?.confidence ?? 0 }
}

final class PouchCellDetector {
    private let request: VNCoreMLRequest
    private let confidenceThreshold: Float

    init(confidenceThreshold: Float = 0.25) throws {
        self.confidenceThreshold = confidenceThreshold

        guard let modelURL = Bundle.main.url(forResource: "PouchCellYolo", withExtension: "mlmodelc") else {
            throw NSError(
                domain: "PouchCellDetector",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "PouchCellYolo.mlmodelc was not found in the app bundle."]
            )
        }

        let mlModel = try MLModel(contentsOf: modelURL)
        let visionModel = try VNCoreMLModel(for: mlModel)
        self.request = VNCoreMLRequest(model: visionModel)
        self.request.imageCropAndScaleOption = .scaleFit
    }

    func detect(in image: UIImage) throws -> PouchCellDetectionResult {
        let normalized = image.normalizedForModel()
        guard let cgImage = normalized.cgImage else {
            throw NSError(
                domain: "PouchCellDetector",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Unable to convert image into CGImage for detection."]
            )
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        try handler.perform([request])

        let observations = request.results as? [VNRecognizedObjectObservation] ?? []
        return PouchCellDetectionResult(observations: observations, confidenceThreshold: confidenceThreshold)
    }

    func crop(image: UIImage, to boundingBox: CGRect, padding: CGFloat = 0.12) -> UIImage? {
        let normalizedImage = image.normalizedForModel()
        guard let cgImage = normalizedImage.cgImage else { return nil }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        var rect = VNImageRectForNormalizedRect(boundingBox, Int(width), Int(height))
        let dx = rect.width * padding
        let dy = rect.height * padding
        rect = rect.insetBy(dx: -dx, dy: -dy)
        rect = rect.intersection(CGRect(x: 0, y: 0, width: width, height: height)).integral

        guard rect.width > 1, rect.height > 1 else { return nil }
        guard let cropped = cgImage.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cropped, scale: normalizedImage.scale, orientation: .up)
    }
}

private extension UIImage {
    func normalizedForModel() -> UIImage {
        if imageOrientation == .up { return self }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
