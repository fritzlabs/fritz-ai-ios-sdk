//
//  CoreMLPredictable.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/2/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
protocol CoreMLPredictor: FritzPredictable, FritzMLModelReadType {

  func predictCoreML(
    _ input: PredictionInput,
    options: ModelOptions,
    completion: (PredictionResult?, Error?) -> Void
  )

  func processCoreMLInput(_ input: PredictionInput, options: ModelOptions) -> MLFeatureProvider?

  func processCoreMLResult(
    results: MLFeatureProvider,
    input: PredictionInput,
    options: ModelOptions
  ) -> PredictionResult?
}

@available(iOS 11.0, *)
extension CoreMLPredictor {

  /// Run image prediction using Core ML directly.  Used to sidestep iOS 12 vision bug.
  func predictCoreML(
    _ input: PredictionInput,
    options: ModelOptions,
    completion: (PredictionResult?, Error?) -> Void
  ) {

    guard let modelInput = processCoreMLInput(input, options: options) else {
      completion(nil, FritzVisionError.errorProcessingImage)
      return
    }

    do {
      let results = try model.prediction(from: modelInput)
      let result = processCoreMLResult(results: results, input: input, options: options)
      completion(result, nil)
    } catch let error {
      completion(nil, error)
      return
    }
  }
}
