//
//  CoreMLOrVisionFrameworkPredictor.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/8/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Predictor that can use both Core ML and the Vision framework for predictions.
@available(iOS 11.0, *)
@available(iOSApplicationExtension 11.0, *)
protocol CoreMLOrVisionPredictor: CoreMLImagePredictor, VisionFrameworkPredictor {}

@available(iOS 11.0, *)
extension CoreMLOrVisionPredictor {

  static func getImageConstraint(for model: FritzMLModel) -> CGSize {
    let imageConstraint = model.modelDescription.inputDescriptionsByName["image"]!.imageConstraint!
    return CGSize(width: imageConstraint.pixelsWide, height: imageConstraint.pixelsHigh)
  }

  func _predict(
    _ fritzImage: PredictionInput,
    options: ModelOptions,
    completion: (PredictionResult?, Error?) -> Void
  ) {

    if options.forceVisionPrediction {
      // Forcing Core ML Prediction if seeing inconsistent results on ios 11.
      predictVisionFramework(fritzImage, options: options, completion: completion)
      return
    }

    if options.forceCoreMLPrediction {
      // Forcing Core ML Prediction if seeing inconsistent results on ios 11.
      predictCoreML(fritzImage, options: options, completion: completion)
      return
    }

    let version = ProcessInfo().operatingSystemVersion

    if version.majorVersion > 12 {
      predictVisionFramework(fritzImage, options: options, completion: completion)
    } else if version.majorVersion == 11, version.minorVersion == 0 {
      predictVisionFramework(fritzImage, options: options, completion: completion)
    } else if version.majorVersion == 12, version.minorVersion >= 2 {
      predictVisionFramework(fritzImage, options: options, completion: completion)
    } else {
      predictCoreML(fritzImage, options: options, completion: completion)
    }
  }
}
