//
//  LabelPredictor+Recordable.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/3/20.
//  Copyright © 2020 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

// MARK: - Image Labeling Data Recording.

@available(iOS 11.0, *)
extension CocoImageAnnotation {

  /// Initialize with a `FritzVisionLabel`.
  public init(label: FritzVisionLabel) {

    self.init(bbox: nil, keypoints: nil, segmentation: nil, label: label.label, isImageLabel: true)
  }
}

@available(iOS 11.0, *)
extension FritzVisionLabel: AnnotationRepresentable {


  /// Create annotation for image label.
  /// - Parameter input: Input image.
  public func annotations(for input: FritzVisionImage) -> [CocoImageAnnotation] {
    return [
      CocoImageAnnotation(label: self)
    ]
  }
}


@available(iOS 12.0, *)
extension FritzVisionLabelPredictor: PredictionImageRecordable {
  public typealias AnnotationRepresentation = [FritzVisionLabel]
}
