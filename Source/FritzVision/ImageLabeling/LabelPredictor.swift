//
//  FritzVisionLabelModel.swift
//  FritzVisionModel
//
//  Created by Christopher Kelly on 6/7/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import AVFoundation
import Foundation
import Vision

@objc(FritzVisionLabelModelOptions)
public final class FritzVisionLabelModelOptions: NSObject, FritzImageOptions {

  public static var defaults: FritzImageOptions = FritzVisionLabelModelOptions()

  /// Confidence threshold for prediction results in the range of [0, 1], default is 0.6.
  @objc public var threshold: Double = 0.6

  /// Force predictions to use Core ML (if supported by model). In iOS 12, scaleFit
  /// would incorrectly crop image.  When True (or on iOS 12) model will run using CoreML.
  @objc public var forceCoreMLPrediction: Bool = true

  /// Force predictions to use the Vision framework (if supported by model).
  ///
  /// Takes precedence over `forceCoreMLPrediction`.  Core ML predictions do not currently work
  /// with YUV pixel formats, which are used in ARKit. Setting this to true will force the
  /// predictor to use the Vision framework.  Unfortunately, in iOS 11.1 - 12.1 there is a
  /// bug that incorrectly crops images with the imageCropAndScaleOption set to `.scaleFit`.
  /// However, if you are using ARKit, you must set this to true.
  @objc public var forceVisionPrediction: Bool = false

  /// Number of results to return from request.
  @objc public var numResults: Int = 15

  @objc public var imageCropAndScaleOption: FritzVisionCropAndScale = .scaleFit
}

@objc public enum FritzVisionLabelError: Int, Error {
  case noVisionModel
}

@available(iOS 11.0, *)
open class FritzVisionLabelPredictor: BasePredictor, CoreMLOrVisionPredictor {

  public typealias PredictionInput = FritzVisionImage
  public typealias ModelOptions = FritzVisionLabelModelOptions
  public typealias PredictionResult = [FritzVisionLabel]

  lazy var visionModel: VNCoreMLModel = getVisionModel()

  func processCoreMLResult(
    results: MLFeatureProvider,
    input: FritzVisionImage,
    options: FritzVisionLabelModelOptions
  ) -> [FritzVisionLabel]? {
    let scores = results.featureValue(for: "confidence")!.dictionaryValue as! [String: Float]
    let labels = scores.map { FritzVisionLabel(label: $0.key, confidence: Double($0.value)) }
    return labels.sorted { $0.confidence > $1.confidence }
      .enumerated()
      .filter { ($0.element.confidence >= options.threshold) && ($0.offset < options.numResults) }
      .map { $0.element }
  }

  func processRequest(
    for request: VNRequest,
    input: FritzVisionImage,
    options: FritzVisionLabelModelOptions
  ) -> [FritzVisionLabel]? {
    return (request.results as! [VNClassificationObservation])
      .sorted { $0.confidence > $1.confidence }
      .enumerated()
      .filter {
        (Double($0.element.confidence) > options.threshold) && ($0.offset < options.numResults)
      }
      .map { $0.element }
      .map { FritzVisionLabel(label: $0.identifier, confidence: Double(Float($0.confidence))) }

  }

  /// Predict poses from a FritzImage.
  ///
  /// - Parameters:
  ///   - input: The image to use to dectect poses.
  ///   - options: The options used to configure the pose results.
  ///   - completion: Handler to call back on the main thread with poses or error.
  @objc(predict:options:completion:)
  public func predict(
    _ input: FritzVisionImage,
    options: FritzVisionLabelModelOptions = .init(),
    completion: ([FritzVisionLabel]?, Error?) -> Void
  ) {
    _predict(input, options: options, completion: completion)
  }
}
