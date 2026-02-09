//
//  ml.swift
//  placeholder
//
//  Created by Oquba Khan on 11/26/25.
//
import UIKit
import CoreGraphics
import CoreML

enum ImagePreprocessing {
    static func imageToGrayscaleVector (_ image: UIImage, size: Int = 128) -> [Double]? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = size
        let height = size
        let count = width * height
        
        var rawData = [UInt8](repeating: 0, count: count)
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.linearGray) ?? CGColorSpaceCreateDeviceGray() as CGColorSpace? else {
            return nil
        }
        
        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            return nil
        }
        
        context.interpolationQuality = .high
        
        context.draw(cgImage, in: CGRect(x: 0, y:0, width: width, height: height))
        
        return rawData.map { Double($0) / 255.0 }
    }
    // Convert [Double] vector to MLMultiArray
       static func vectorToMultiArray(_ v: [Double]) -> MLMultiArray? {
           guard v.count == 128 * 128 else { return nil }
           guard let arr = try? MLMultiArray(shape: [NSNumber(value: v.count)], dataType: .double) else { return nil }

           // Fast fill using pointer
           let ptr = arr.dataPointer.bindMemory(to: Double.self, capacity: v.count)
           for i in 0..<v.count { ptr[i] = v[i] }

           return arr
       }

       // Convenience: UIImage -> MLMultiArray directly
       static func imageToGrayscaleMultiArray(_ image: UIImage, size: Int = 128) -> MLMultiArray? {
           guard let v = imageToGrayscaleVector(image, size: size) else { return nil }
           return vectorToMultiArray(v)
       }
}
