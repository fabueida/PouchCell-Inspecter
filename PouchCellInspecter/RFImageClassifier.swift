//
//  RFImageClassifier.swift
//  PouchCellInspecter
//
//  Created by Oquba Khan on 2/11/26.
//

import CoreML
import Vision
import UIKit

final class RFImageClassifier {
    private let model: RFClassifier
    private let classNames = [
        0: "Normal",
        1: "Bulging",
        2: "Unknown"
    ]
    
    init() {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        self.model = try! RFClassifier(configuration: config)
    }
    
    func classify(_ image: UIImage) throws -> PredictionResult {
        guard let inputArray = ImagePreprocessing.imageToGrayscaleMultiArray(image) else {
            throw NSError(
                domain: "RFImageClassifier",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to preprocess image into MLMultiArray"]
            )
        }
        let out = try model.prediction(input: inputArray)
        
        let labelRaw = Int(out.classLabel)
        
        guard let label = classNames[labelRaw] else {
            throw NSError(
                domain: "RFImageClassifier",
                code: -2,
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
