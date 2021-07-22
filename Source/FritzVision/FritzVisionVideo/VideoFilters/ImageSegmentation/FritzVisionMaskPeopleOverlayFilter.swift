//
//  FritzVisionMaskPeopleOverlayFilter.swift
//  FritzVision
//
//  Created by Steven Yeung on 10/29/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Creates a mask over all detected people.
@available(iOS 11.0, *)
public class FritzVisionMaskPeopleOverlayFilter: FritzVisionSegmentationFilter {
  
  public let compositionMode = FilterCompositionMode.overlayOnOriginalImage
  public let model: FritzVisionSegmentationPredictor
  public let options: FritzVisionSegmentationMaskOptions
  
  public init(
    model: FritzVisionPeopleSegmentationPredictor,
    options: FritzVisionSegmentationMaskOptions = .init()
  ) {
    self.model = model
    self.options = options
  }
  
  public func process(_ image: FritzVisionImage) -> FritzVisionFilterResult {
    do {
      let result = try model.predict(image)
      if let mask = result.buildSingleClassMask(
        forClass: FritzVisionPeopleClass.person,
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
