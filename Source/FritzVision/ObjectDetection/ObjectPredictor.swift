//
//  FritzVisionObjectModel.swift
//
//
//  Created by Christopher Kelly on 6/29/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import AVFoundation
import Foundation
import FritzManagedModel
import Vision

@objc(FritzVisionObjectModelOptions)
public final class FritzVisionObjectModelOptions: NSObject, FritzImageOptions {

  /// Confidence threshold for prediction results in the range of [0, 1], default is 0.6.
  @objc public var threshold: Double = 0.6

  /// Threshold for overlap of items within a single class in range [0, 1].  Lower values are more strict.
  @objc public var iouThreshold: Double = 0.25

  /// Number of results to return from request.
  @objc public var numResults: Int = 15

  @objc public var imageCropAndScaleOption: FritzVisionCropAndScale = .scaleFit

  /// Force predictions to use Core ML (if supported by model). In iOS 12, scaleFit
  /// would incorrectly crop image.  When True (or on iOS 12) model will run using CoreML.
  @objc public let forceCoreMLPrediction: Bool = true

  /// Force predictions to use the Vision framework (if supported by model).
  ///
  /// Takes precedence over `forceCoreMLPrediction`.  Core ML predictions do not currently work
  /// with YUV pixel formats, which are used in ARKit. Setting this to true will force the
  /// predictor to use the Vision framework.  Unfortunately, in iOS 11.1 - 12.1 there is a
  /// bug that incorrectly crops images with the imageCropAndScaleOption set to `.scaleFit`.
  /// However, if you are using ARKit, you must set this to true.
  @objc public var forceVisionPrediction: Bool = false

  public static var defaults: FritzImageOptions = FritzVisionObjectModelOptions()
}

@objc(FritzVisionObjectPredictor)
@available(iOS 12.0, *)
public class FritzVisionObjectPredictor: BasePredictor, CoreMLImagePredictor {

  private let processingType: ObjectDetectionBoxType

  @objc(initWithModel:)
  public override init(model: FritzMLModel) {
    do {
      self.processingType = try ObjectDetectionBoxType.getType(from: model)
      super.init(model: model)
    } catch let error as FritzObjectModelSpecificationError {
      fatalError(error.message())
    } catch {
      fatalError("Invalid model")
    }
  }

  @objc(initWithModel:managedModel:)
  public override init(model: FritzMLModel, managedModel: FritzManagedModel) {
    do {
      self.processingType = try ObjectDetectionBoxType.getType(from: model)
      super.init(model: model, managedModel: managedModel)
    } catch let error as FritzObjectModelSpecificationError {
      fatalError(error.message())
    } catch {
      fatalError("Invalid model")
    }
  }

  /// Initialize Object model using a custom model with accessible class names.
  /// For models with built-in post processing and built-in class names.
  /// Uses default class names as a fall back if none are found.
  ///
  /// - Parameters:
  ///   - model: IdentifiedModel to use
  @objc(initWithIdentifiedModel:)
  public override init(model: SwiftIdentifiedModel) {
    do {
      self.processingType = try ObjectDetectionBoxType.getType(from: model.model)
      super.init(model: model)
    } catch let error as FritzObjectModelSpecificationError {
      fatalError(error.message())
    } catch {
      fatalError("Invalid model")
    }
  }

  /// Initialize Object model using a custom model with the given class names.
  /// For models with built-in post processing without built-in class names.
  ///
  /// - Parameters:
  ///   - identifiedModel: IdentifiedModel to use
  ///   - classNames: Labels for objects
  @objc(initWithIdentifiedModel:processedLabels:)
  public init(identifiedModel: SwiftIdentifiedModel, classNames: [String]) {
    do {
      let model = identifiedModel.fritzModel()
      let managedModel = FritzManagedModel(identifiedModel: identifiedModel)
      self.processingType = try ObjectDetectionBoxType.getType(from: model, with: classNames)
      super.init(model: model, managedModel: managedModel)
    } catch let error as FritzObjectModelSpecificationError {
      fatalError(error.message())
    } catch {
      fatalError("Invalid model")
    }
  }

  func processCoreMLResult(
    results: MLFeatureProvider,
    input: FritzVisionImage,
    options: FritzVisionObjectModelOptions
  ) -> [FritzVisionObject]? {
    var boxPredictions: MLMultiArray
    var classPredictions: MLMultiArray
    var postProcessor: PostProcessor

    // Able to force unwrap due to prior validation.
    switch processingType {
    case .anchorBox(let classConfidenceKey, let anchorBoxKey, let labels):
      boxPredictions = results.featureValue(for: anchorBoxKey)!.multiArrayValue!
      classPredictions = results.featureValue(for: classConfidenceKey)!.multiArrayValue!
      postProcessor
        = AnchorBoxPostProcessor(
          imageHeight: Double(input.size.height),
          imageWidth: Double(input.size.height),
          classNames: labels
        )
      break
    case .boundingBox(let confidenceKey, let boundingBoxKey, let labels):
      boxPredictions = results.featureValue(for: boundingBoxKey)!.multiArrayValue!
      classPredictions = results.featureValue(for: confidenceKey)!.multiArrayValue!
      postProcessor = BoundingBoxPostProcessor(classNames: labels)
      break
    }

    let predictions = postProcessor.postProcess(
      boxPredictions: boxPredictions,
      classPredictions: classPredictions,
      options: options
    )

    return predictions.map { value in
      let label = FritzVisionLabel(label: value.detectedClassLabel, confidence: value.score)
      return FritzVisionObject(
        label: label,
        boundingBox: BoundingBox(from: value.boundingBox),
        bounds: CGSize(width: 1.0, height: 1.0)
      )
    }
  }

  func processCoreMLInput(
    _ input: FritzVisionImage,
    options: FritzVisionObjectModelOptions
  ) -> MLFeatureProvider? {
    let imageConstraint = Self.getImageConstraint(for: model)
    guard
      let image = input.prepare(
        size: imageConstraint,
        scaleCropOption: options.imageCropAndScaleOption
      )
    else {
      return nil
    }
    return ObjectDetectionInputProvider(
      image: image,
      iouThreshold: options.iouThreshold,
      confidenceThreshold: options.threshold
    )
  }

  /// Run prediction for vision object model.
  ///
  /// - Parameters:
  ///   - input: Image or buffer to run model on.
  ///   - options: Options for model execution.
  ///   - completion: The block to invoke after the prediction request has finished processing.
  @objc(predict:options:completion:)
  public func predict(
    _ input: FritzVisionImage,
    options: FritzVisionObjectModelOptions = .init(),
    completion: ([FritzVisionObject]?, Error?) -> Void
  ) {
    _predict(input, options: options, completion: completion)
  }
}

@available(iOS 12.0, *)
private enum ObjectDetectionBoxType {
  case anchorBox(classConfidenceKey: String, anchorBoxKey: String, labels: [String])
  case boundingBox(confidenceKey: String, boundingBoxKey: String, labels: [String])

  /// Determines the proper model type of the given model based on its input and output names.
  ///
  /// - Parameters:
  ///   - model: Model to correctly type.
  ///   - classNames: Class names for the model.
  static func getType(
    from model: MLModel,
    with classNames: [String]? = nil
  ) throws -> ObjectDetectionBoxType {
    guard let _ = model.modelDescription.inputDescriptionsByName[ObjectModelSpec.imageInputKey]
    else {
      throw FritzObjectModelSpecificationError.invalidInput
    }
    if let anchorBox = validateAsAnchorBox(from: model, with: classNames) {
      return anchorBox
    }
    if let boundingBox = validateAsBoundingBox(from: model, with: classNames) {
      return boundingBox
    }
    throw FritzObjectModelSpecificationError.invalidOutput
  }

  private static func validateAsAnchorBox(
    from model: MLModel,
    with classNames: [String]?
  ) -> ObjectDetectionBoxType? {
    let outputNames = model.modelDescription.outputDescriptionsByName

    guard
      let offsetOut = outputNames[ObjectModelSpec.anchorBoxModel.offsetOutputKey],
      let predictionOut = outputNames[ObjectModelSpec.anchorBoxModel.predictionOutputKey]
    else { return nil }

    return .anchorBox(
      classConfidenceKey: offsetOut.name,
      anchorBoxKey: predictionOut.name,
      labels: classNames ?? Array(LABELS.values)
    )
  }

  private static func validateAsBoundingBox(
    from model: MLModel,
    with classNames: [String]?
  ) -> ObjectDetectionBoxType? {
    let inputNames = model.modelDescription.inputDescriptionsByName
    let outputNames = model.modelDescription.outputDescriptionsByName

    guard
      let _ = inputNames[ObjectModelSpec.boundingBoxModel.confidenceInputKey],
      let _ = inputNames[ObjectModelSpec.boundingBoxModel.iouInputKey],
      let confidenceOut = outputNames[ObjectModelSpec.boundingBoxModel.confidenceOutputKey],
      let boxOut = outputNames[ObjectModelSpec.boundingBoxModel.coordinateOutputKey]
    else { return nil }

    var targetLabels = classNames
    if let modelInfo = model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey]
      as? [String: String]
    {
      targetLabels
        = modelInfo[ObjectModelSpec.boundingBoxModel.classInputKey]?.components(separatedBy: ",")
    }

    return .boundingBox(
      confidenceKey: confidenceOut.name,
      boundingBoxKey: boxOut.name,
      labels: targetLabels ?? Array(LABELS.values)
    )
  }
}

internal enum FritzObjectModelSpecificationError: Error {
  case invalidInput
  case invalidOutput

  func message() -> String {
    switch self {
    case .invalidInput:
      return """
        Model has invalid inputs.

        All models must contain an image input.
        Models with processing must contain the following additional inputs: "confidenceThreshold", "iouThreshold"

        For additional help, reach out on the help center at https://docs.fritz.ai/help-center/index.html
        """
    case .invalidOutput:
      return """
        Model has invalid outputs.

        Models without processing must contain the following outputs: "class_predictions", "bbox_offsets"
        Models with processing must contain the following outputs: "confidence", "coordinates"

        For additional help, reach out on the help center at https://docs.fritz.ai/help-center/index.html
        """
    }
  }
}
