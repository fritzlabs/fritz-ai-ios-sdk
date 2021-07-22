//
//  CoreMLImagePredictor.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/2/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
protocol CoreMLImagePredictor: FritzVisionImagePredictable, CoreMLPredictor {}

@available(iOS 11.0, *)
extension CoreMLImagePredictor {

  static func getImageConstraint(for model: FritzMLModel) -> CGSize {
    let imageConstraint = model.modelDescription.inputDescriptionsByName["image"]!.imageConstraint!
    return CGSize(width: imageConstraint.pixelsWide, height: imageConstraint.pixelsHigh)
  }

  func processCoreMLInput(_ input: PredictionInput, options: ModelOptions) -> MLFeatureProvider? {
    // NOTE (chris): I believe forced unwrapping is okay as all models we provide have "image" as the input name and
    // are Image types.
    let imageConstraint = Self.getImageConstraint(for: model)

    guard
      let image = input.prepare(
        size: imageConstraint,
        scaleCropOption: options.imageCropAndScaleOption
      )
    else {
      return nil
    }

    return ImageInputProvider(image: image)
  }

  public func _predict(
    _ input: PredictionInput,
    options: ModelOptions,
    completion: (PredictionResult?, Error?) -> Void
  ) {
    predictCoreML(input, options: options, completion: completion)
  }
}
