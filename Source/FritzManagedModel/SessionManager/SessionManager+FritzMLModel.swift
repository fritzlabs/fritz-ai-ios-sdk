//
//  SessionManager+ManagedModel.swift
//  Fritz
//
//  Created by Andrew Barba on 07/14/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import FritzCore

internal enum SessionManagerError: Error {
  case disabled
  case downloadMissingModelURL
  case missingCaseStatement
}

// MARK: - Measure
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SessionManager {

  /// Measures a predication result and reports to API
  func measurePrediction(_ result: PredictionResult, forManagedModel model: FritzMLModel) {

    let options: RequestOptions = [
      "is_ota": model.activeModelConfig.isOTA,
      "model_version": model.version,
      "model_uid": model.id,
      "elapsed_nano_seconds": result.predicationElapsedTime,
      "uses_cpu_only": result.predictionOptions?.usesCPUOnly ?? false,
    ]

    trackEvent(.init(type: .prediction, data: options))
  }

  /// Samples input/output data from a prediction result
  func sampleInputOutput(_ result: PredictionResult, forManagedModel model: FritzMLModel) {
    guard session.settings.shouldSampleInputOutput() else {
      return
    }

    var options: RequestOptions = [
      "input": result.predictionInput.toJSON(),
      "model_uid": model.id,
      "model_version": model.version,
    ]

    if let output = result.predictionOutput {
      options["output"] = output.toJSON()
    }

    if let error = result.predictionError {
      logger.error("Model Prediction Error:", options, error)
      options["error"] = error.toJSON()
    }

    trackEvent(.init(type: .inputOutputSample, data: options))
  }
}

// MARK: - Install
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SessionManager {

  /// Reports install of a model.
  func reportInstall(forManagedModel model: FritzMLModel) {
    logger.debug("Reporting Model Install:", model.id)

    let options: RequestOptions = [
      "is_ota": model.activeModelConfig.isOTA,
      "model_version": model.version,
      "model_uid": model.id,
    ]

    trackEvent(.init(type: .modelInstalled, data: options))
  }
}
