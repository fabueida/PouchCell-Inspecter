import UIKit
import Vision

struct ScanPipelineResult {
    let resultText: String
    let displayImage: UIImage
}

final class ScanAnalysisService {
    static let shared = ScanAnalysisService()

    private let classifier = RFImageClassifier()
    private let detector: PouchCellDetector? = try? PouchCellDetector(confidenceThreshold: 0.5)

    private init() {}

    func analyzeImage(_ image: UIImage) -> ScanPipelineResult {
        let preparedImage = image.scaledDownForAnalysis(maxDimension: 1600)

        guard let detector else {
            return ScanPipelineResult(
                resultText: "Unknown - detector unavailable",
                displayImage: preparedImage.scaledDownForDisplay(maxDimension: 1200)
            )
        }

        do {
            let detection = try detector.detect(in: preparedImage)

            guard let bestObservation = detection.bestObservation else {
                return ScanPipelineResult(
                    resultText: "Unknown - no pouch cell detected",
                    displayImage: preparedImage.scaledDownForDisplay(maxDimension: 1200)
                )
            }

            let cropped = detector.crop(image: preparedImage, to: bestObservation.boundingBox) ?? preparedImage
            let classification = try classifier.classify(cropped)
            let confidence = classification.topK.first?.prob ?? 0.0
            let displayImage = cropped.scaledDownForDisplay(maxDimension: 1200)

            guard confidence >= 0.55 else {
                return ScanPipelineResult(
                    resultText: "Unknown - low classification confidence",
                    displayImage: displayImage
                )
            }

            return ScanPipelineResult(
                resultText: "\(classification.classLabel) - \(String(format: "%.2f", confidence * 100))%",
                displayImage: displayImage
            )
        } catch {
            return ScanPipelineResult(
                resultText: "Unknown - analysis failed",
                displayImage: preparedImage.scaledDownForDisplay(maxDimension: 1200)
            )
        }
    }
}

private extension UIImage {
    func scaledDownForAnalysis(maxDimension: CGFloat) -> UIImage {
        resizedIfNeeded(maxDimension: maxDimension)
    }

    func scaledDownForDisplay(maxDimension: CGFloat) -> UIImage {
        resizedIfNeeded(maxDimension: maxDimension)
    }

    private func resizedIfNeeded(maxDimension: CGFloat) -> UIImage {
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension, longestSide > 0 else { return self }

        let scaleRatio = maxDimension / longestSide
        let newSize = CGSize(width: size.width * scaleRatio, height: size.height * scaleRatio)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
