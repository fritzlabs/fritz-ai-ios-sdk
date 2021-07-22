//
//  ObjectDetectionProvider.swift
//  Fritz
//
//  Created by Steven Yeung on 10/10/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
public class ObjectDetectionInputProvider: MLFeatureProvider {

  var image: CVPixelBuffer? = nil

  /// Remove bounding boxes below this threshold (confidences should be nonnegative). as optional double value
  var confidenceThreshold: Double? = nil

  /// This defines the radius of suppression. as optional double value
  var iouThreshold: Double? = nil

  public var featureNames: Set<String> {
    return [
      ObjectModelSpec.imageInputKey,
      ObjectModelSpec.boundingBoxModel.confidenceInputKey,
      ObjectModelSpec.boundingBoxModel.iouInputKey
    ]
  }

  public func featureValue(for featureName: String) -> MLFeatureValue? {
    if featureName == ObjectModelSpec.imageInputKey,
      let image = image
    {
      return MLFeatureValue(pixelBuffer: image)
    }
    if featureName == ObjectModelSpec.boundingBoxModel.confidenceInputKey,
      let confidenceThreshold = confidenceThreshold
    {
      return MLFeatureValue(double: confidenceThreshold)
    }
    if featureName == ObjectModelSpec.boundingBoxModel.iouInputKey,
      let iouThreshold = iouThreshold
    {
      return MLFeatureValue(double: iouThreshold)
    }
    return nil
  }

  public init(
    image: CVPixelBuffer? = nil,
    iouThreshold: Double? = nil,
    confidenceThreshold: Double? = nil
  ) {
    self.image = image
    self.iouThreshold = iouThreshold
    self.confidenceThreshold = confidenceThreshold
  }
}
