//
//  FritzVisionMaskHairOverlayFilter.swift
//  FritzVision
//
//  Created by Steven Yeung on 10/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Creates a mask of a person's hair.
@available(iOS 11.0, *)
public class FritzVisionMaskHairOverlayFilter: FritzVisionSegmentationFilter {
  
  public let compositionMode = FilterCompositionMode.overlayOnOriginalImage
  public let model: FritzVisionSegmentationPredictor
  public let options: FritzVisionSegmentationMaskOptions
  
  public init(
    model: FritzVisionHairSegmentationPredictor,
    options: FritzVisionSegmentationMaskOptions = .init()
  ) {
    self.model = model
    self.options = options
  }
  
  public func process(_ image: FritzVisionImage) -> FritzVisionFilterResult {
    do {
      let result = try model.predict(image)
      if let mask = result.buildSingleClassMask(
        forClass: FritzVisionHairClass.hair,
        options: options,
        resize: true
        ) {
        return .success(FritzVisionImage(image: mask))
      }
      return .failure(FritzVisionVideoError.invalidPrediction)
    } catch let error {
      return .failure(error)
    }
  }
}
