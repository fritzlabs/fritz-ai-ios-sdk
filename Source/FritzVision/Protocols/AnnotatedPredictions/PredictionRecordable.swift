//
//  PredictionRecordable.swift
//  FritzVision
//
//  Created by Christopher Kelly on 11/13/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Adds functionality to record annotated model predictions.
///
/// You can record prediction results as a way to collect data on model performance.
@available(iOS 11.0, *)
public protocol PredictionRecordable: FritzPredictable {

  /// Annotation Representation can be different than the `PredictionResult` type.
  /// More processing may happen for the `PredictionResult` to represent an annotation.
  /// For example, the `FritzVisionPosePredictor` returns a `PoseResult` type; however, the pose
  /// can look different depending on different thresholds passed to the pose result.
  associatedtype AnnotationRepresentation: AnnotationRepresentable
    where AnnotationRepresentation.Source == PredictionInput,
      AnnotationRepresentation.Source: Base64StringEncodable

  var model: FritzMLModel { get }

  /// Reports the results of a prediction to Fritz API used for collecting
  /// diagnostic data on model predictions.
  ///
  /// - Parameters:
  ///   - input: Prediction input.
  ///   - predictedRepresentation: Results from model prediction (after postprocessing from result class has
  ///   been applied).
  ///   - modifiedRepresentation: Optional user-modified results from predictions.
  func record(
    _ input: PredictionInput,
    predicted predictedRepresentation: AnnotationRepresentation,
    modified modifiedRepresentation: AnnotationRepresentation?
  ) -> SessionEvent?
}

@available(iOS 11.0, *)
extension PredictionRecordable {

  @discardableResult
  public func record(
    _ input: PredictionInput,
    predicted predictedRepresentation: AnnotationRepresentation,
    modified modifiedRepresentation: AnnotationRepresentation? = nil
  ) -> SessionEvent? {
    let imageAnnotation = DataAnnotationRecording(
      input: input,
      modelConfig: model.activeModelConfig,
      predicted: predictedRepresentation,
      modified: modifiedRepresentation
    )
    guard let event = try? imageAnnotation.event() else {
      return nil
    }

    model.sessionManager.trackAnnotation(event)
    return event
  }
  
}


/// Adds functionality to report annotations for models with a `FritzVisionImage` input.
@available(iOS 11.0, *)
public protocol PredictionImageRecordable: PredictionRecordable
where AnnotationRepresentation.Source == FritzVisionImage {

  associatedtype PredictionInput = FritzVisionImage

}

@available(iOS 11.0, *)
extension PredictionImageRecordable {

  internal var maxDimensionSize: CGFloat { 1000 }

  @discardableResult
  public func record(
    _ input: FritzVisionImage,
    predicted predictedRepresentation: AnnotationRepresentation,
    modified modifiedRepresentation: AnnotationRepresentation? = nil
  ) -> SessionEvent? {
    guard let resized = input.resized(withMaxDimensionLessThan: maxDimensionSize) else {
      return nil
    }

    let imageAnnotation = DataAnnotationRecording(
      input: resized,
      modelConfig: model.activeModelConfig,
      predicted: predictedRepresentation,
      modified: modifiedRepresentation
    )
    guard let event = try? imageAnnotation.event() else {
      return nil
    }

    model.sessionManager.trackAnnotation(event)
    return event
  }

}
