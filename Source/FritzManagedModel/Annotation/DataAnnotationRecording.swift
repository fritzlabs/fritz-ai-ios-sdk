//
//  DataAnnotationRecording.swift
//  FritzManagedModel
//
//  Created by Christopher Kelly on 11/13/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
public class DataAnnotationRecording<AnnotationRepresentation: AnnotationRepresentable>
where AnnotationRepresentation.Source: Base64StringEncodable {

  let maxSize: CGFloat = 1000

  /// Input to model for annotation
  let input: AnnotationRepresentation.Source

  /// Model configuration of prediction.
  let modelConfig: FritzModelConfiguration

  /// Predicted object that can generated an annotation.
  let predicted: AnnotationRepresentation

  /// Annotation representation that has been modified from raw prediction - generally by additional user input.
  let modified: AnnotationRepresentation?

  public init(
    input: AnnotationRepresentation.Source,
    modelConfig: FritzModelConfiguration,
    predicted predictionRepresentation: AnnotationRepresentation,
    modified modifiedRepresentation: AnnotationRepresentation? = nil) {
    self.input = input
    self.modelConfig = modelConfig
    self.predicted = predictionRepresentation
    self.modified = modifiedRepresentation
  }

  /// Creates SessionEvent for reporting to API.
  public func event() throws -> SessionEvent {
    var options: RequestOptions = [
      "input": try input.encode(),
      "input_width": try input.encodedImageDimensions().width,
      "input_height": try input.encodedImageDimensions().height,
      "input_type": input.encodedFormat.rawValue,
      "model_version": modelConfig.version,
      "model_uid": modelConfig.identifier,
      "predicted_annotations": predicted.annotations(for: input).map { $0.requestOptions }
    ]

    if let modified = modified {
      options["modified_annotations"] = modified.annotations(for: input).map { $0.requestOptions }
    }

    return SessionEvent(type: .predictionAnnotation, data: options)
  }
}
