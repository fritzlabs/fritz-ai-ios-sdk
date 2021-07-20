//
//  FritzVisionCutOutPeopleOverlayFilter.swift
//  FritzVision
//
//  Created by Steven Yeung on 11/18/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Cuts out all detected people from the background.
@available(iOS 11.0, *)
public class FritzVisionCutOutPeopleOverlayFilter: FritzVisionSegmentationFilter {
  
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
        ),
        let peopleMasked = image.masked(with: mask)
      {
        return .success(FritzVisionImage(image: peopleMasked))
      }
      return .failure(FritzVisionVideoError.invalidPrediction)
    } catch let error {
      return .failure(error)
    }
  }
}
