//
//  FritzVisionBlendHairCompoundFilter.swift
//  FritzVision
//
//  Created by Steven Yeung on 10/29/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Creates a blended mask of a person's hair.
@available(iOS 11.0, *)
public class FritzVisionBlendHairCompoundFilter: FritzVisionSegmentationFilter {

  public let compositionMode = FilterCompositionMode.compoundWithPreviousOutput
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
        resize: false
        ),
        let blended = image.blend(
          withMask: mask,
          blendKernel: .softLight,
          opacity: 0.7
        )
      {
        return .success(FritzVisionImage(image: blended))
      }
      return .failure(FritzVisionVideoError.invalidPrediction)
    } catch let error {
      return .failure(error)
    }
  }
}
