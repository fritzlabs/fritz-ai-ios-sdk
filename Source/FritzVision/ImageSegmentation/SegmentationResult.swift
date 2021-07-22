//
//  FritzVisionSegmentationResult.swift
//  FritzVisionSegmentationPredictor
//
//  Created by Christopher Kelly on 10/1/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import AVFoundation
import Accelerate
import Foundation

// MARK: - Segmentation Result
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
@objc(FritzVisionSegmentationResult)
public class FritzVisionSegmentationResult: NSObject, FritzPredictionResult {

  /// Height of model output array.
  @objc public let height: Int

  /// Width of model output array.
  @objc public let width: Int

  /// Model classes.
  @objc public let classes: [ModelSegmentationClass]

  /// Raw MLMultiArray result from prediction.
  @objc public let predictionResult: MLMultiArray

  internal let maskArray: MultiArray<Double>
  internal let imageSize: CGSize
  internal let cropOption: FritzVisionCropAndScale

  internal init(
    array: MultiArray<Double>,
    imageSize: CGSize,
    classes: [ModelSegmentationClass],
    cropOption: FritzVisionCropAndScale
  ) {
    self.maskArray = array
    self.predictionResult = array.array
    self.height = array.shape[1]
    self.width = array.shape[2]
    self.classes = classes
    self.imageSize = imageSize
    self.cropOption = cropOption
  }

  func convertMultiClassValuesToColor(
    for values: [Int32],
    alpha: UInt8
  ) -> [UInt8] {

    var colorArray = [UInt8](repeating: 0, count: classes.count * 4)
    for i in 0..<classes.count {
      let cls = classes[i]
      colorArray[i * 4] = cls.color.r
      colorArray[i * 4 + 1] = cls.color.g
      colorArray[i * 4 + 2] = cls.color.b
      colorArray[i * 4 + 3] = alpha
    }

    var mutableValues = values
    var output = [UInt8](repeating: 0, count: values.count * 4)
    classesToColor(&mutableValues, &colorArray, &output, values.count)

    return output
  }

  func convertSingleClassConfidenceScoresToColor(
    for values: [Float],
    color: rgbaValue,
    alpha: UInt8
  ) -> [UInt8] {
    var value = values
    var destBytes = [Float](repeating: 0, count: height * width * 4)
    var destBytesUint8 = [UInt8](repeating: 0, count: height * width * 4)

    var r: Float = Float(color.r)
    var g: Float = Float(color.g)
    var b: Float = Float(color.b)
    var a: Float = Float(alpha)

    let stride = 4
    
    destBytes.withUnsafeMutableBufferPointer { destBytesPointer in
      vDSP_vsmul(&value, 1, &r, destBytesPointer.baseAddress! + 0, stride, vDSP_Length(height * width))
      vDSP_vsmul(&value, 1, &g, destBytesPointer.baseAddress! + 1, stride, vDSP_Length(height * width))
      vDSP_vsmul(&value, 1, &b, destBytesPointer.baseAddress! + 2, stride, vDSP_Length(height * width))
      vDSP_vsmul(&value, 1, &a, destBytesPointer.baseAddress! + 3, stride, vDSP_Length(height * width))
    }

    // Convert to uint8
    vDSP_vfixu8(&destBytes, 1, &destBytesUint8, 1, vDSP_Length(height * width * 4))

    return destBytesUint8
  }

  /// Gets a height * width length array with each entry the most likely class for that pixel.
  ///
  /// Optionally choose the minimum acceptable confidence score for a class to be chosen.
  ///
  /// - Parameter minimumConfidence: Minimum confidence score needed for class to be chosen.
  /// - Returns: 1D-Array of length [height x width].
  public func getArrayOfMostLikelyClasses(
    withMinimumConfidenceScore minimumConfidence: Double = 0.0
  ) -> [Int32] {
    let pixelCount = height * width
    var bytes = [Float](repeating: 0, count: pixelCount * classes.count)
    var reducedMask = [Int32](repeating: 0, count: pixelCount)
    vDSP_vdpsp(maskArray.pointer, 1, &bytes, 1, vDSP_Length(pixelCount * classes.count))
    argmax(&bytes, &reducedMask, Float(minimumConfidence), classes.count, pixelCount)
    return reducedMask
  }

  @objc(getArrayOfConfidenceScoresforClass:ClippingAbove:zeroingBelow:)
  func getArrayOfConfidenceScores(
    forClass segmentClass: ModelSegmentationClass,
    clippingScoresAbove threshold: Double = 0.5,
    zeroingScoresBelow minThreshold: Double = 0.5
  ) -> [Float] {
    let pixelCount = height * width
    var bytes = [Float](repeating: 0, count: pixelCount * classes.count)
    var reducedMask = [Float](repeating: 0, count: pixelCount)

    // Double to Float
    bytes.withUnsafeMutableBufferPointer { bytesBufferPointer in
      vDSP_vdpsp(maskArray.pointer, 1, bytesBufferPointer.baseAddress!, 1, vDSP_Length(pixelCount * classes.count))

      // If the the min accepted value is the same as the threshold, it is a binary result and is slightly faster to use the non-fuzzy algorithm.
      // Otherwise, the following will be true.  Values above the threshold will be 1. Values below the minAccepted value will be 0, and values
      // between the minAccepted and threshold values will be their original probabilities.
      if minThreshold == threshold {
        arrayThreshold(
          bytesBufferPointer.baseAddress! + pixelCount * segmentClass.index,
          &reducedMask,
          Float(threshold),
          height * width
        )
      } else {
        fuzzyArrayThreshold(
          bytesBufferPointer.baseAddress! + pixelCount * segmentClass.index,
          &reducedMask,
          Float(threshold),
          Float(minThreshold),
          height * width
        )
      }
    }
    return reducedMask
  }
  
  /// Gets segmentation masks for a specific class.
  ///
  /// The Segmentation object returned are used to send data back to the Fritz webapp for additional data annotation, model evaluation, and retraining.
  /// For a mask that can be used for computer vision applications in your app, see methods such as `buildMask`
  ///
  /// - Parameter segmentationClass: the class to generate a mask for
  /// - Parameter clippingThreshold: pixels with confidence scores above this threshold will be assigned to the class, pixels below the threshold are assigned 0 values.
  /// - Parameter areaThreshold: the fraction of the total image area an object mask must be for inclusion in an annotation. This value is used to filter out small, spurrious segmentations.
  public func segmentationMask(
    forClass segmentClass: ModelSegmentationClass,
    clippingThreshold threshold: Double = 0.5,
    areaThreshold: Double = 0.1
  ) -> Segmentation? {
    let mask = getArrayOfConfidenceScores(forClass: segmentClass, clippingScoresAbove: threshold, zeroingScoresBelow: threshold)
    let area = Double(mask.compactMap { $0 } .reduce(0.0, +)) / Double(self.height * self.width)
    if area < areaThreshold { return nil }
    return Segmentation(mask: try! mask.as2D(width: width, height: height), label: segmentClass.label)
  }
  
  /// Gets segmentation masks for all classes predicted by a model.
  ///
  /// These masks are objects used to send data back to the Fritz webapp for additional data annotation, model evaluation, and retraining.
  /// For segmentation objects that can be used for computer vision applications in your app, see methods such as `buildMask`
  ///
  /// - Parameter confidenceThreshold: pixels with confidence scores above this threshold are included in the binary mask
  /// - Parameter areaThreshold: the fraction of the total image area an object mask must be for inclusion in an annotation. This value is used to filter out small, spurrious segmentations.
  public func segmentationMasks(confidenceThreshold: Double = 0.5, areaThreshold: Double = 0.1) -> [Segmentation] {
    return self.classes.map { (segmentationClass) -> Segmentation? in
      self.segmentationMask(forClass: segmentationClass, clippingThreshold: confidenceThreshold, areaThreshold: areaThreshold) } .compactMap { $0 }
  }
}
