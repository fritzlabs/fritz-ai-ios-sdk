//
//  VisionPredictable.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/2/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
protocol VisionCoreMLModelReadType: FritzMLModelReadType {
  var visionModel: VNCoreMLModel { get }
}

@available(iOS 11.0, *)
extension VisionCoreMLModelReadType {

  func getVisionModel() -> VNCoreMLModel {
    guard let visionModel = try? VNCoreMLModel(for: model) else {
      fatalError("Can't load VisionML model")
    }
    return visionModel
  }
}

@available(iOS 11.0, *)
protocol VisionFrameworkPredictor: FritzVisionImagePredictable, VisionCoreMLModelReadType {

  func processRequest(
    for request: VNRequest,
    input: PredictionInput,
    options: ModelOptions
  ) -> PredictionResult?

  func predictVisionFramework(
    _ input: PredictionInput,
    options: ModelOptions,
    completion: (PredictionResult?, Error?) -> Void
  )
}

// MARK - VisionFrameworkPredictor implementation.
@available(iOS 11.0, *)
extension VisionFrameworkPredictor {

  static func getImageConstraint(for model: FritzMLModel) -> CGSize {
    let imageConstraint = model.modelDescription.inputDescriptionsByName["image"]!.imageConstraint!
    return CGSize(width: imageConstraint.pixelsWide, height: imageConstraint.pixelsHigh)
  }

  func predictVisionFramework(
    _ input: PredictionInput,
    options: ModelOptions,
    completion: (PredictionResult?, Error?) -> Void
  ) {
    var result: PredictionResult?
    var resultError: Error?

    let trackingRequest = VNCoreMLRequest(model: visionModel) { (request, error) in
      if let error = error {
        resultError = error
      } else {
        result = self.processRequest(for: request, input: input, options: options)
      }
    }

    trackingRequest.imageCropAndScaleOption = options.imageCropAndScaleOption.visionOption
    guard let imageRequestHandler = input.buildImageRequestHandler() else {
      return completion(nil, FritzVisionError.invalidImageBuffer)
    }

    do {
      try imageRequestHandler.perform([trackingRequest])
      completion(result, resultError)
    } catch {
      completion(nil, error)
    }
  }

  func _predict(
    _ input: PredictionInput,
    options: ModelOptions,
    completion: (PredictionResult?, Error?) -> Void
  ) {
    predictVisionFramework(input, options: options, completion: completion)
  }
}
