//
//  DTImageClassifier.swift
//  PouchCellInspecter
//
//  Created by Oquba Khan on 1/30/26.
//

import CoreML
import Vision
import UIKit

struct PredictionResult {
    let classLabel: String
    let probabilities: [Int: Double]
    let topK: [(label: Int, prob: Double)]
}

final class DTImageClassifier {
    private let model: DTClassifier
    private let classNames: [Int: String] = [
        0: "Bulging",
        1: "Normal"
    ]

    init() {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        self.model = try! DTClassifier(configuration: config)
    }

    func classify(_ image: UIImage) throws -> PredictionResult {
        guard let inputArray = ImagePreprocessing.imageToGrayscaleMultiArray(image) else {
            throw NSError(
                domain: "DTImageClassifier",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to preprocess image into MLMultiArray"]
            )
        }

        let out = try model.prediction(input: inputArray)

        // Robust parsing in case CoreML generated `classLabel` as Int64 or String
        let rawLabelString = String(describing: out.classLabel)
        guard let labelRaw = Int(rawLabelString) else {
            throw NSError(
                domain: "DTImageClassifier",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Unexpected classLabel format: \(rawLabelString)"]
            )
        }

        guard let label = classNames[labelRaw] else {
            throw NSError(
                domain: "DTImageClassifier",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Unknown class label index: \(labelRaw)"]
            )
        }

        var probs: [Int: Double] = [:]

        let rawProbs: [Int64: Double] = out.classProbability
        for (k, v) in rawProbs {
            probs[Int(k)] = v
        }

        let topK = probs
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { (label: $0.key, prob: $0.value) }

        return PredictionResult(classLabel: label, probabilities: probs, topK: topK)
    }
}

// Optional compatibility alias (helps if any file still references the older typo name)
typealias DTIImageClassifier = DTImageClassifier

