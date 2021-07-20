//
//  ImageInputFeatureProvider.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/2/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class ImageInputProvider: MLFeatureProvider {

  /// image as color (kCVPixelFormatType_32BGRA) image buffer, 768 pixels wide by 768 pixels high
  var image: CVPixelBuffer

  var featureNames: Set<String> {
    return ["image"]
  }

  func featureValue(for featureName: String) -> MLFeatureValue? {
    if featureName == "image" {
      return MLFeatureValue(pixelBuffer: image)
    }
    return nil
  }

  init(image: CVPixelBuffer) {
    self.image = image
  }
}
