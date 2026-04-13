//
//  PouchCellDetector.swift
//  PouchCellInspector
//
//  Created by Firas Abueida on 1/1/26.
//

import CoreML
import Vision
import UIKit

struct PouchCellDetectionResult {
    let observations: [VNRecognizedObjectObservation]
    let confidenceThreshold: Float

    var detectedObservations: [VNRecognizedObjectObservation] {
        observations.filter { $0.confidence >= confidenceThreshold }
    }

    var hasPouchCell: Bool {
        !detectedObservations.isEmpty
    }

    var bestObservation: VNRecognizedObjectObservation? {
        detectedObservations.max(by: { $0.confidence < $1.confidence })
    }

    var bestConfidence: Float {
        bestObservation?.confidence ?? 0
    }
}

final class PouchCellDetector {
    private let visionModel: VNCoreMLModel
    private let confidenceThreshold: Float

    init(confidenceThreshold: Float = 0.5) throws {
        self.confidenceThreshold = confidenceThreshold

        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all

        guard let modelURL = Bundle.main.url(forResource: "PouchCellYolo", withExtension: "mlmodelc") else {
            throw NSError(
                domain: "PouchCellDetector",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "PouchCellYolo.mlmodelc was not found in the app bundle."]
            )
        }

        let mlModel = try MLModel(contentsOf: modelURL, configuration: configuration)
        self.visionModel = try VNCoreMLModel(for: mlModel)
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

        var capturedResults: [VNRecognizedObjectObservation] = []

        let request = VNCoreMLRequest(model: visionModel) { request, error in
            if let error = error {
                print("PouchCellDetector Vision error: \(error.localizedDescription)")
                capturedResults = []
                return
            }

            capturedResults = request.results as? [VNRecognizedObjectObservation] ?? []
        }

        request.imageCropAndScaleOption = .scaleFill
        request.preferBackgroundProcessing = true

        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: .up,
            options: [:]
        )

        try handler.perform([request])

        return PouchCellDetectionResult(
            observations: capturedResults,
            confidenceThreshold: confidenceThreshold
        )
    }

    func crop(image: UIImage, to boundingBox: CGRect, padding: CGFloat = 0.12) -> UIImage? {
        let normalizedImage = image.normalizedForModel()

        guard let cgImage = normalizedImage.cgImage else { return nil }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        var rect = VNImageRectForNormalizedRect(
            boundingBox,
            Int(width),
            Int(height)
        )

        let dx = rect.width * padding
        let dy = rect.height * padding
        rect = rect.insetBy(dx: -dx, dy: -dy)

        rect = rect
            .intersection(CGRect(x: 0, y: 0, width: width, height: height))
            .integral

        guard rect.width > 1, rect.height > 1 else { return nil }
        guard let cropped = cgImage.cropping(to: rect) else { return nil }

        return UIImage(
            cgImage: cropped,
            scale: normalizedImage.scale,
            orientation: .up
        )
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
