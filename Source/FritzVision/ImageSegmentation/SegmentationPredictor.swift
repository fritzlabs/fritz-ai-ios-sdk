//
//  FritzVisionImageSegmentationModel.swift
//  Heartbeat
//
//  Created by Christopher Kelly on 9/12/18.
//  Copyright © 2018 Fritz Labs, Inc. All rights reserved.
//

import AVFoundation
import Accelerate
import Foundation
import Vision

@objc(FritzVisionSegmentationModelOptions)
public final class FritzVisionSegmentationModelOptions: NSObject, FritzImageOptions {
  
  public static var defaults: FritzImageOptions = FritzVisionSegmentationModelOptions()
  
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
}

@objc(ModelSegmentationClass)
public class ModelSegmentationClass: NSObject {
  
  /// Index in output array from model.
  @objc public let index: Int
  
  /// Label name for Model Segmentation Class.
  @objc public let label: String
  
  public let color: rgbaValue
  
  public init(label: String, index: Int, color: rgbaValue) {
    self.label = label
    self.index = index
    self.color = color
  }
}

@objc(FritzVisionSegmentationModel)
@available(iOS 11.0, *)
@available(*, deprecated, renamed: "FritzVisionSegmentationPredictor")
open class FritzVisionSegmentationModel: FritzVisionSegmentationPredictor { }

@objc(FritzVisionSegmentationPredictor)
@available(iOS 11.0, *)
open class FritzVisionSegmentationPredictor: BasePredictor, CoreMLOrVisionPredictor {
  
  @objc public let classes: [ModelSegmentationClass]
  
  lazy var visionModel: VNCoreMLModel = getVisionModel()
  
  @objc(initWithModel:classes:)
  public init(model: FritzMLModel, classes: [ModelSegmentationClass]? = nil) {
    do {
      if let classes = classes {
        self.classes = classes
      } else {
        self.classes = try FritzVisionSegmentationPredictor.classMetadata(from: model)
      }
      super.init(model: model)
    } catch let error as FritzSegmentationModelSpecificationError {
      fatalError(error.message)
    } catch {
      fatalError("Invalid Model")
    }
  }
  
  @objc(initWithModel:classes:managedModel:)
  public init(
    model: FritzMLModel,
    classes: [ModelSegmentationClass]? = nil,
    managedModel: FritzManagedModel
  ) {
    
    do {
      if let classes = classes {
        self.classes = classes
      } else {
        self.classes = try FritzVisionSegmentationPredictor.classMetadata(from: model)
      }
      super.init(model: model, managedModel: managedModel)
    } catch let error as FritzSegmentationModelSpecificationError {
      fatalError(error.message)
    } catch {
      fatalError("Invalid Model")
    }
  }
  
  @objc(initWithIdentifiedModel:classes:)
  public init(model: SwiftIdentifiedModel, classes: [ModelSegmentationClass]? = nil) {
    let mlmodel = model.fritzModel()
    
    do {
      if let classes = classes {
        self.classes = classes
      } else {
        self.classes = try FritzVisionSegmentationPredictor.classMetadata(from: mlmodel)
      }
      super.init(model: mlmodel)
    } catch let error as FritzSegmentationModelSpecificationError {
      fatalError(error.message)
    } catch {
      fatalError("Invalid Model")
    }
  }
  
  static func classMetadata(from model: MLModel) throws -> [ModelSegmentationClass] {
    // First load classes from model metadata.
    if let modelInfo = model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey]
      as? [String: String]
    {
      if let labels = modelInfo[SegmentationModelSpec.classInputKey]?.components(separatedBy: ",") {
        return labels.enumerated().map { (index, label) in
          ModelSegmentationClass(
            label: label,
            index: index,
            color: FritzVisionSegmentationPredictor.labelColor(for: label, index: index)
          )
        }
      }
    }
    throw FritzSegmentationModelSpecificationError.noClassesInMetadata
  }
  
  static func labelColor(for label: String, index: Int) -> rgbaValue {
    // Create color based on position in a color wheel
    // Artificially increasing index for better color variety
    let color = UIColor(
      hue: CGFloat(index * 10) / 359.0,
      saturation: 1.0,
      brightness: 1.0,
      alpha: 1.0
    ).rgbaValue
    if let color = color, label != "None" {
      return color
    }
    return (0, 0, 0, 0)
  }
  
  func processRequest(
    for request: VNRequest,
    input: FritzVisionImage,
    options: FritzVisionSegmentationModelOptions
  ) -> FritzVisionSegmentationResult? {
    let results = request.results as! [VNCoreMLFeatureValueObservation]
    let values = results[0].featureValue.multiArrayValue!
    return FritzVisionSegmentationResult(
      array: MultiArray<Double>(values),
      imageSize: input.size,
      classes: self.classes,
      cropOption: options.imageCropAndScaleOption
    )
  }
  
  func processCoreMLResult(
    results: MLFeatureProvider,
    input: FritzVisionImage,
    options: FritzVisionSegmentationModelOptions
  ) -> FritzVisionSegmentationResult? {
    let featureValue = results.featureValue(for: SegmentationModelSpec.maskOutputKey)!.multiArrayValue
    return FritzVisionSegmentationResult(
      array: MultiArray<Double>(featureValue!),
      imageSize: input.size,
      classes: classes,
      cropOption: options.imageCropAndScaleOption
    )
  }
  
  /// Run image segmentation on a FritzVisionImage.
  ///
  /// - Parameters:
  ///   - input: Image or buffer to run model on.
  ///   - options: Options for model execution.
  ///   - completion: The block to invoke after the prediction request.  Contains a FritzVisionSegmentationResult or error message.
  @objc(predict:options:completion:)
  public func predict(
    _ input: FritzVisionImage,
    options: FritzVisionSegmentationModelOptions = .init(),
    completion: (FritzVisionSegmentationResult?, Error?) -> Void
  ) {
    _predict(input, options: options, completion: completion)
  }
}

internal enum FritzSegmentationModelSpecificationError: Error {
  case noClassesInMetadata
  
  var message: String {
    switch self {
    case .noClassesInMetadata:
      return """
      No labels were found in the MLModel's metadata.
      
      Either add a comma-separated list of labels to the userDefinedMetadata property of the mlmodel or pass a list of [ModelSegmentationClass] to the FritzVisionSegmentationPredictor constructor.
      """
    }
  }
}
