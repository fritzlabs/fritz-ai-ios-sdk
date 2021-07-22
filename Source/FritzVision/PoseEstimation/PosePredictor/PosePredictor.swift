//
//  FritzVisionPoseModel.swift
//  FritzVision
//
//  Created by Christopher Kelly on 1/31/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Options for Pose Model.
@objc(FritzVisionPoseModelOptions)
public final class FritzVisionPoseModelOptions: NSObject, FritzImageOptions {

  /// Default Pose model options.
  public static let defaults: FritzImageOptions = FritzVisionPoseModelOptions()

  /// Crop and scale option. Default value is scaleFit.
  @objc public var imageCropAndScaleOption: FritzVisionCropAndScale = .scaleFit

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

  /// Minimum score a part must have to potentially build a new pose. The pose will include parts below this
  /// threshold, but a part below this threshold will not trigger a new pose instance to be built.
  @objc public var minPartThreshold: Double = 0.50

  /// Minimum score a pose must have to be included in results.
  @objc public var minPoseThreshold: Double = 0.50

  /// NMS radius for pose
  @objc public var nmsRadius: Int = 20

  public var smoothingOptions: OneEuroPointFilter.Options? = OneEuroPointFilter.low
}

fileprivate let kOutputStrideKey = "output_stride"

@available(iOS 11.0, *)
extension MLModel {
  /// Output stride of model

  fileprivate var outputStride: Int? {
    if let creatorMetadata = self.modelDescription.metadata[.creatorDefinedKey] as? [String:
      String],
      let outputStride = creatorMetadata[kOutputStrideKey]
    {
      return Int(outputStride)
    }
    return nil
  }

}

/// A model used to predict the poses of people in images.
@available(iOS 11.0, *)
open class FritzVisionPosePredictor<Skeleton: SkeletonType>: BasePredictor, CoreMLOrVisionPredictor
{

  public typealias PredictionInput = FritzVisionImage
  public typealias ModelOptions = FritzVisionPoseModelOptions
  public typealias PredictionResult = FritzVisionPoseResult<Skeleton>
  

  lazy var visionModel: VNCoreMLModel = getVisionModel()

  /// Model Configuration for pose model in Fritz.
  public var outputStride: Int = 8

  public var useDisplacements: Bool = true

  private let numKeypoints = Skeleton.allCases.count

  private var poseSmoother: MultiPoseSmoother<OneEuroPointFilter, Skeleton>?

  private var smoothingOptions: OneEuroPointFilter.Options? {
    didSet {
      if poseSmoother == nil, let smoothingOptions = smoothingOptions {
        poseSmoother
          = MultiPoseSmoother<OneEuroPointFilter, Skeleton>(
            numKeypoints: numKeypoints,
            options: smoothingOptions
          )
      }
      if smoothingOptions == nil {
        poseSmoother = nil
      }
    }
  }

  /// Initialize model with FritzMLModel. If output_stride key defined in userDefinedMetadata,
  /// Model will be initialized with that stride.
  ///
  /// - Parameter model: FritzMLModel
  @objc(initWithModel:)
  public override init(model: FritzMLModel) {
    if let outputStride = model.outputStride {
      self.outputStride = outputStride
    }
    super.init(model: model)
  }

  /// Initialize model with FritzMLModel. If output_stride key defined in userDefinedMetadata,
  /// Model will be initialized with that stride.
  ///
  /// - Parameter model: FritzMLModel
  @objc(initWithIdentifiedModel:)
  public override init(model: SwiftIdentifiedModel) {
    if let outputStride = model.model.outputStride {
      self.outputStride = outputStride
    }
    super.init(model: model)
  }

  /// Initialize model with FritzMLModel. If output_stride key defined in userDefinedMetadata,
  /// Model will be initialized with that stride.
  ///
  /// - Parameter model: FritzMLModel
  /// - Parameter managedModel: FritzManagedModel
  @objc(initWithModel:managedModel:)
  public override init(model: FritzMLModel, managedModel: FritzManagedModel) {
    if let outputStride = model.outputStride {
      self.outputStride = outputStride
    }
    super.init(model: model, managedModel: managedModel)
  }

  func processCoreMLResult(
    results: MLFeatureProvider,
    input: FritzVisionImage,
    options: FritzVisionPoseModelOptions
  ) -> FritzVisionPoseResult<Skeleton>? {
    smoothingOptions = options.smoothingOptions
    let imageConstraint = Self.getImageConstraint(for: model)
    let smootheFunc = { (poses: [Pose<Skeleton>]) in
      self.poseSmoother?.smoothe(poses) ?? poses
    }

    return FritzVisionPoseResult<Skeleton>(
      for: results,
      modelInputSize: imageConstraint,
      with: input,
      options: options,
      outputStride: outputStride,
      smootheFunc: smootheFunc,
      useDisplacements: useDisplacements
    )
  }

  func processRequest(
    for request: VNRequest,
    input: FritzVisionImage,
    options: FritzVisionPoseModelOptions
  ) -> FritzVisionPoseResult<Skeleton>? {
    smoothingOptions = options.smoothingOptions
    let results = request.results as! [VNCoreMLFeatureValueObservation]
    let imageConstraint = Self.getImageConstraint(for: model)

    let smootheFunc = { (poses: [Pose]) in
      self.poseSmoother?.smoothe(poses) ?? poses
    }

    if results.count > 2 {
      guard let displacementsFwd = results[0].featureValue.multiArrayValue,
        let displacementsBwd = results[1].featureValue.multiArrayValue,
        let heatmapScores = results[2].featureValue.multiArrayValue,
        let offsets = results[4].featureValue.multiArrayValue
      else { return nil }
      return FritzVisionPoseResult<Skeleton>(
        heatmapScores: heatmapScores,
        offsets: offsets,
        displacementsFwd: displacementsFwd,
        displacementsBwd: displacementsBwd,
        modelInputSize: imageConstraint,
        withImage: input,
        options: options,
        outputStride: outputStride,
        smootheFunc: smootheFunc,
        useDisplacements: useDisplacements
      )

    } else {
      guard let heatmapScores = results[0].featureValue.multiArrayValue,
        let offsets = results[1].featureValue.multiArrayValue
      else { return nil }
      return FritzVisionPoseResult<Skeleton>(
        heatmapScores: heatmapScores,
        offsets: offsets,
        displacementsFwd: nil,
        displacementsBwd: nil,
        modelInputSize: imageConstraint,
        withImage: input,
        options: options,
        outputStride: outputStride,
        smootheFunc: smootheFunc,
        useDisplacements: useDisplacements
      )
    }
  }

  /// Predict poses from a FritzImage.
  ///
  /// - Parameters:
  ///   - input: The image to use to dectect poses.
  ///   - options: The options used to configure the pose results.
  ///   - completion: Handler to call back on the main thread with poses or error.
  public func predict(
    _ input: FritzVisionImage,
    options: FritzVisionPoseModelOptions = .init(),
    completion: (FritzVisionPoseResult<Skeleton>?, Error?) -> Void
  ) {
    _predict(input, options: options, completion: completion)
  }
}
