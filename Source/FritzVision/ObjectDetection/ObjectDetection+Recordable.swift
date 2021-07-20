//
//  ObjectDetection+Recordable.swift
//  FritzVision
//
//  Created by Christopher Kelly on 2/5/20.
//  Copyright © 2020 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

// MARK: - Object Prediction Data Recording.

@available(iOS 11.0, *)
extension CocoImageAnnotation {

  /// Initialize with a `FritzVisionObject`.
  public init(object: FritzVisionObject) {
    let bbox = object.boundingBox

    self.init(bbox: BoundingBox(rect: bbox.cgRect), keypoints: [], segmentation: nil, label: object.label)
  }
}

@available(iOS 11.0, *)
extension FritzVisionObject: AnnotationRepresentable {


  /// Create annotations for object resized to input image size.
  /// - Parameter input: Input image.
  public func annotations(for input: FritzVisionImage) -> [CocoImageAnnotation] {
    let scaled = self.scaled(to: input.size)
    return [
      CocoImageAnnotation(object: scaled)
    ]
  }
}


@available(iOS 12.0, *)
extension FritzVisionObjectPredictor: PredictionImageRecordable {
  public typealias AnnotationRepresentation = [FritzVisionObject]
}
