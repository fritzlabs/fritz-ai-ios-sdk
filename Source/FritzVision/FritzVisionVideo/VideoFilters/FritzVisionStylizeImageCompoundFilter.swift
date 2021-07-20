//
//  FritzStyleModelFilter.swift
//  FritzVision
//
//  Created by Steven Yeung on 10/29/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Stylizes the input image.
@available(iOS 11.0, *)
public class FritzVisionStylizeImageCompoundFilter: FritzVisionImageFilter {

  public let compositionMode = FilterCompositionMode.compoundWithPreviousOutput
  public let model: FritzVisionStylePredictor
  public let options: FritzVisionStyleModelOptions

  public init(
    model: FritzVisionStylePredictor,
    options: FritzVisionStyleModelOptions = .init()
  ) {
    self.model = model
    self.options = options
  }

  public func process(_ image: FritzVisionImage) -> FritzVisionFilterResult {
    do {
      let styleBuffer = try self.model.predict(image, options: options)
      return .success(FritzVisionImage(ciImage: CIImage(cvPixelBuffer: styleBuffer)))
    } catch let error {
      return .failure(error)
    }
  }
}
