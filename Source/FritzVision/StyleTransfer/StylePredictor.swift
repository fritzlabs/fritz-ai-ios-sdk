//
//  FritzVisionStyleModelBase.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 8/9/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import CoreML
import Foundation
import Vision

@available(*, deprecated, renamed: "FlexibleModelDimensions")
@objc(StyleOutputDimensions)
public class StyleOutputDimensions: FlexibleModelDimensions {}

@objc(FlexibleModelDimensions)
/// Specify dimensions for how to run flexible models. Calling `init` with no arguments will cause the model to run on original file size.
public class FlexibleModelDimensions: NSObject {

  public let size: CGSize?


  @objc(init)
  override public init() {
    self.size = nil
    super.init()
  }

  @objc(initWithSize:)
  public init(size: CGSize) {
    self.size = size
  }

  @objc(initWithWidth:withHeight:)
  public init(width: Int, height: Int) {
    self.size = CGSize(width: width, height: height)
  }
}

extension FlexibleModelDimensions {
  /// Use original image dimensions.  Model will throw an error if image dimensions are not within range of acceptable input sizes.
  @objc public static let original = FlexibleModelDimensions()

  @objc public static let lowResolution = FlexibleModelDimensions(width: 480, height: 640)
  @objc public static let mediumResolution = FlexibleModelDimensions(width: 720, height: 1280)
  @objc public static let highResolution = FlexibleModelDimensions(width: 1080, height: 1920)
}

/// Options for running style transfer models.
@objc(FritzVisionStyleModelOptions)
public final class FritzVisionStyleModelOptions: NSObject, FritzImageOptions {

  /// Crop and scale option. Default option is .scaleFit.
  @objc public var imageCropAndScaleOption: FritzVisionCropAndScale = .scaleFit

  /// Force predictions to use Core ML (if supported by model).
  /// In iOS 12, scaleFit would incorrectly crop image.  When True (or on iOS 12) model will run using CoreML.
  @objc public var forceCoreMLPrediction: Bool = true

  /// Force predictions to use the Vision framework (if supported by model).
  /// If you are using ARKit, you must set this to true.
  @objc public var forceVisionPrediction: Bool = false

  /// Resize the output to match the FritzVisionImage size.
  @objc public var resizeOutputToInputDimensions: Bool = false

  /// Sets dimensions of input image for flexible model. Note that setting this to higher resolutions will increase
  /// model processing time.
  @objc public var flexibleModelDimensions: FlexibleModelDimensions = .mediumResolution

  public static var defaults: FritzImageOptions = FritzVisionStyleModelOptions()
}

internal enum StyleKeywords: String {
  case image = "image"
  case stylized = "stylizedImage"
}

@available(*, deprecated, renamed: "FritzVisionStylePredictor")
@available(iOS 12.0, *)
public class FritzVisionFlexibleStyleModel: FritzVisionStylePredictor {}

@available(*, deprecated, renamed: "FritzVisionStylePredictor")
@available(iOS 11.0, *)
public class FritzVisionStyleModel: FritzVisionStylePredictor {}

/// Construct a Flexible Style Transfer model and run on any FritzVisionImage.
/// Produces stylized images with customizable output sizes.
@available(iOS 11.0, *)
@objc(FritzVisionStylePredictor)
public class FritzVisionStylePredictor: NSObject, CoreMLOrVisionPredictor, FritzMLModelInitializable
{

  public typealias PredictionInput = FritzVisionImage
  public typealias ModelOptions = FritzVisionStyleModelOptions
  public typealias PredictionResult = CVPixelBuffer

  let model: FritzMLModel
  lazy var visionModel: VNCoreMLModel = getVisionModel()
  @objc public let managedModel: FritzManagedModel

  fileprivate static let logger = Logger(name: "FritzVisionStylePredictor")

  /// Validate model to make sure it contains the proper input and output specs.
  /// Will add some basic protections so that users don't provide invalid models, thinking it will work.
  ///
  /// - Parameters:
  ///   - model: MLModel to verify.
  internal static func validateModel(model: MLModel) throws {
    guard
      let imageInput = model.modelDescription.inputDescriptionsByName[StyleKeywords.image.rawValue],
      let _ = imageInput.imageConstraint
    else {
      throw FritzStyleModelSpecificationError.invalidInput
    }
    guard
      let imageOutput = model.modelDescription.outputDescriptionsByName[
        StyleKeywords.stylized.rawValue],
      let _ = imageOutput.imageConstraint
    else {
      throw FritzStyleModelSpecificationError.invalidOutput
    }
  }

  /// Initialize FritzStyleTransferModel with your own trained style model.
  ///
  /// - Parameters:
  ///   - model: Fritz model to use.
  @objc(initWithIdentifiedModel:)
  convenience public required init(model: SwiftIdentifiedModel) {
    do {
      let managedModel = FritzManagedModel(identifiedModelType: type(of: model))
      try self.init(model: model.fritzModel(), managedModel: managedModel)
    } catch let error as FritzStyleModelSpecificationError {
      fatalError(error.message())
    } catch {
      fatalError("Invalid Model")
    }
  }

  /// Initialize FritzVisionStylePredictor with your own trained style model.
  ///
  /// - Parameters:
  ///   - model: Fritz model to use.
  @objc(initWithFritzMLModel:error:)
  required public init(model: FritzMLModel) throws {
    self.model = model
    self.managedModel
      = FritzManagedModel(
        modelConfig: model.activeModelConfig,
        sessionManager: model.sessionManager,
        loadActiveFromDisk: false
      )
    try FritzVisionStylePredictor.validateModel(model: model)
  }

  /// Initialize FritzVisionStylePredictor with your own trained style model.
  ///
  /// - Parameters:
  ///   - model: Fritz model to use.
  ///   - managedModel: FritzManagedModel to use.
  @objc(initWithFritzMLModel:managedModel:error:)
  required public init(model: FritzMLModel, managedModel: FritzManagedModel) throws {
    self.model = model
    self.managedModel = managedModel
    try FritzVisionStylePredictor.validateModel(model: model)
  }

  /// Run Style Transfer on a FritzVisionImage.
  ///
  /// - Parameters:
  ///   - input: Image or buffer to run model on.
  ///   - options: Options for model execution.
  ///   - completion: The block to invoke after the prediction request.
  ///                 Contains a FritzVisionSegmentationResult or error message.
  @objc(predict:options:completion:)
  public func predict(
    _ input: FritzVisionImage,
    options: FritzVisionStyleModelOptions = .init(),
    completion: (CVPixelBuffer?, Error?) -> Void
  ) {
    if #available(iOS 12.0, *) {
      switch constraints.type {
      case .range:
        // Only using Core ML with Flexible model because it's easier to control input size.
        predictFlexibleInput(input, options: options, completion: completion)
      case .enumerated, .unspecified:
        _predict(input, options: options, completion: completion)
      @unknown default:
        completion(nil, FritzStyleModelSpecificationError.invalidInput)
      }
    } else {
      _predict(input, options: options, completion: completion)
    }
  }

  /// Completes proccessing of a prediction request by resizing the output, if desired.
  ///
  /// - Parameters:
  ///   - imageBuffer: The result of the prediction
  ///   - input: The original image used in the prediction
  ///   - options: Options for model execution.
  internal func processCoreMLOrVisionResult(
    _ imageBuffer: CVPixelBuffer,
    for input: FritzVisionImage,
    options: FritzVisionStyleModelOptions
  ) -> CVPixelBuffer? {
    if !options.resizeOutputToInputDimensions {
      return imageBuffer
    }
    let image = CIImage(cvPixelBuffer: imageBuffer)
    let pipeline = CIImagePipeline(image)
    pipeline.resize(CGSize(width: input.size.width, height: input.size.height))
    return pipeline.render()
  }
}

@available(iOS 11.0, *)
extension FritzVisionStylePredictor {

  func processCoreMLResult(
    results: MLFeatureProvider,
    input: FritzVisionImage,
    options: FritzVisionStyleModelOptions
  ) -> CVPixelBuffer? {
    guard
      let imageBuffer = results.featureValue(
        for: StyleKeywords.stylized.rawValue
      )!.imageBufferValue
    else { return nil }

    return processCoreMLOrVisionResult(imageBuffer, for: input, options: options)
  }

  func processRequest(
    for request: VNRequest,
    input: FritzVisionImage,
    options: FritzVisionStyleModelOptions
  ) -> CVPixelBuffer? {
    let results = request.results as! [VNPixelBufferObservation]
    let imageBuffer = results[0].pixelBuffer

    return processCoreMLOrVisionResult(imageBuffer, for: input, options: options)
  }
}

@available(iOS 12.0, *)
extension FritzVisionStylePredictor {

  private var constraints: MLImageSizeConstraint {
    let description = model.modelDescription.inputDescriptionsByName[StyleKeywords.image.rawValue]!
    return description.imageConstraint!.sizeConstraint
  }

  /// Run using Core ML directly.  Used to sidestep iOS 12 vision bug.
  ///
  /// - Parameters:
  ///   - fritzImage: The image to run the prediction on
  ///   - options: Options for model execution
  ///   - completion: The block to invoke after the prediction request.
  ///                 Contains a FritzVisionSegmentationResult or error message.
  func predictFlexibleInput(
    _ fritzImage: FritzVisionImage,
    options: FritzVisionStyleModelOptions,
    completion: (CVPixelBuffer?, Error?) -> Void
  ) {
    do {
      let desiredSize = try getImageDimensions(
        desiredDimensions: options.flexibleModelDimensions,
        for: fritzImage
      )
      guard
        let image = fritzImage.prepare(
          size: desiredSize,
          scaleCropOption: options.imageCropAndScaleOption
        )
      else {
        completion(nil, FritzVisionError.errorProcessingImage)
        return
      }
      let results = try model.prediction(from: ImageInputProvider(image: image))
      guard
        let featureValue = results.featureValue(
          for: StyleKeywords.stylized.rawValue
        )!.imageBufferValue
      else {
        completion(nil, FritzVisionError.invalidImageBuffer)
        return
      }
      let result = processCoreMLOrVisionResult(featureValue, for: fritzImage, options: options)
      completion(result, nil)
    } catch let error {
      completion(nil, error)
      return
    }
  }

  /// Build Image Dimensions for flexible model dimensions.
  ///
  /// - Parameters:
  ///   - desiredDimensions: Expected output dimensions.
  ///   - image: Image used when desired dimensions are from image.
  internal func getImageDimensions(
    desiredDimensions: FlexibleModelDimensions,
    for image: FritzVisionImage
  ) throws -> CGSize {
    var computedHeight: Int
    var computedWidth: Int

    switch constraints.type {
    case .range:
      let heightRange = constraints.pixelsHighRange
      let widthRange = constraints.pixelsWideRange
      let lowerBound = CGSize(width: widthRange.lowerBound, height: heightRange.lowerBound)
      let upperBound = CGSize(width: widthRange.upperBound - 1, height: heightRange.upperBound - 1)

      guard let desiredSize = desiredDimensions.size else {
        // If there is no desired size, use the original image size if it's within model boundaries.
        let size = image.size
        if heightRange.contains(Int(size.height)), widthRange.contains(Int(size.width)) {
          return size
        } else {
          throw FritzStyleModelSpecificationError.invalidImageSize(
            minDimensions: lowerBound,
            maxDimensions: upperBound
          )
        }
      }
      let desiredHeight = Int(desiredSize.height)
      let desiredWidth = Int(desiredSize.width)

      if heightRange.contains(Int(desiredHeight)) {
        computedHeight = desiredHeight
      } else {
        throw FritzStyleModelSpecificationError.invalidImageSize(
          minDimensions: lowerBound,
          maxDimensions: upperBound
        )
      }

      if widthRange.contains(Int(desiredWidth)) {
        computedWidth = desiredWidth
      } else {
        throw FritzStyleModelSpecificationError.invalidImageSize(
          minDimensions: lowerBound,
          maxDimensions: upperBound
        )
      }
    case .enumerated, .unspecified:
      throw FritzStyleModelSpecificationError.invalidFlexibleModelType
    @unknown default:
      throw FritzStyleModelSpecificationError.invalidInput
    }

    return CGSize(width: computedWidth, height: computedHeight)
  }
}

@available(iOS 11.0, *)
extension FritzVisionStylePredictor {
  /// Model metadata set in webapp.
  @objc public var metadata: ModelMetadata? {
    return model.activeModelConfig.metadata
  }

  /// Model tags set in webapp.
  @objc public var tags: [String]? {
    return model.activeModelConfig.tags
  }
}

@available(iOS 11.0, *)
extension FritzVisionStylePredictor {

  /// Fetch and load Style Models for the given tags.
  ///
  /// Note that this instantiates all models which could cause memory pressure if you are loading many models.
  /// If you do not want to immediately instantiate the models, create a ModelTagManager and manage loading yourself.
  ///
  /// - Parameters:
  ///   - tags: List of tags to load models for.
  ///   - wifiRequiredForModelDownload: If true, client must be connected to a wifi network to download a model. Default is false.
  ///   - completionHandler: Completion handler with instantiated FritzVisionStylePredictors
  @objc(fetchStyleModelsForTags:wifiRequiredForModelDownload:withCompletionHandler:)
  public static func fetchStyleModelsForTags(
    tags: [String],
    wifiRequiredForModelDownload: Bool = false,
    completionHandler: @escaping ([FritzVisionStylePredictor]?, Error?) -> Void
  ) {
    _fetchModelsForTags(
      tags: tags,
      wifiRequiredForModelDownload: wifiRequiredForModelDownload
    ) { results, error in
      completionHandler(results as! [FritzVisionStylePredictor]?, error)
    }
  }
}

internal enum FritzStyleModelSpecificationError: Error {
  case invalidInput
  case invalidOutput
  case invalidFlexibleModelType
  case invalidImageSize(minDimensions: CGSize, maxDimensions: CGSize)

  func message() -> String {
    switch self {
    case .invalidInput:
      return """
        Model must contain an image input.

        Make sure that style model was created using the Fritz Style Model Training template.
        """
    case .invalidOutput:
      return """
        Model must contain an image output named stylizedImage.

        Makue sure that style model was created using the Fritz Style Model Training template.
        """
    case .invalidFlexibleModelType:
      return """
        Currently Fritz Flexible Model only supports MLImageSizeConstraint.range.
        """
    case let .invalidImageSize(minDimensions, maxDimensions):
      return """
        Image must fit within bounds of flexible image model dimensions (\(minDimensions.width)x\(minDimensions.height) - \(maxDimensions.width)x\(maxDimensions.height)) if not specifying desired image size.
        """
    }
  }
}
