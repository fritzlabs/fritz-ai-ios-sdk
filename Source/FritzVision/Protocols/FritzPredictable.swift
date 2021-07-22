//
//  FritzPredictor.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/2/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Public protocol exposing main interface for Fritz predictors.
// This protocol does not expose the underlying method for predictions. These could be a Core ML model, or
// Vision model. Protocols or classes that implement this protocol should specify specifics.
@available(iOS 11.0, *)
public protocol FritzPredictable: FritzManagedModelType {

  associatedtype PredictionInput: FritzPredictionInput
  associatedtype ModelOptions: FritzPredictorOptionType
  associatedtype PredictionResult: FritzPredictionResult

  func predict(
    _ input: PredictionInput,
    options: ModelOptions,
    completion: (PredictionResult?, Error?) -> Void
  )

  func predict(_ input: PredictionInput, options: ModelOptions) throws -> PredictionResult
}

@available(iOS 11.0, *)
extension FritzPredictable {

  /// Run Predictor on input.
  ///
  /// - Parameters:
  ///   - input: Input to predictor
  ///   - options: Options for predictor
  /// - Returns: Prediction result, if no error
  /// - Throws: Error encountered during prediction
  public func predict(
    _ input: PredictionInput,
    options: ModelOptions = .init()
  ) throws -> PredictionResult {
    var predictResult: PredictionResult!
    var predictError: Error?
    predict(input, options: options) { result, error in
      if let result = result {
        predictResult = result
      } else if let error = error {
        predictError = error
      } else if result == nil {
        predictError = FritzVisionError.errorProcessingImage
      }
    }
    if let error = predictError {
      throw error
    }
    return predictResult
  }
}
