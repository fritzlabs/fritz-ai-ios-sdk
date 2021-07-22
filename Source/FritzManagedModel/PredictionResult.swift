//
//  PredictionResult.swift
//  Fritz
//
//  Created by Andrew Barba on 9/22/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import CoreML
import FritzCore

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
internal final class PredictionResult {

  /// Input to the model
  let predictionInput: MLFeatureProvider

  /// Options for the prediction
  let predictionOptions: MLPredictionOptions?

  /// Point in time when we started the prediction
  let predictionDate: Date

  /// Time when we started the prediction, used to calculate precise elapsed time
  let predicationElapsedTime: UInt64

  /// Result of the prediction, if successful
  let predictionOutput: MLFeatureProvider?

  /// Prediction error, if failed
  let predictionError: Error?

  /// Returns the MLModel result
  let predictionResult: () throws -> MLFeatureProvider

  /// Init
  init(
    input: MLFeatureProvider,
    options: MLPredictionOptions?,
    predictionBlock: () throws -> MLFeatureProvider
  ) {
    self.predictionInput = input
    self.predictionOptions = options
    self.predictionDate = Date()
    let start = DispatchTime.now().uptimeNanoseconds
    do {
      let output = try predictionBlock()
      self.predictionOutput = output
      self.predictionError = nil
      self.predictionResult = { output }
    } catch {
      self.predictionOutput = nil
      self.predictionError = error
      self.predictionResult = { throw error }
    }
    self.predicationElapsedTime = DispatchTime.now().uptimeNanoseconds - start
  }
}
