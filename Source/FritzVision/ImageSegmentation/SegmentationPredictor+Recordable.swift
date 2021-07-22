//
//  SegmentationPredictor+Recordable.swift
//  Fritz
//
//  Created by Jameson Toole on 5/14/20.
//  Copyright © 2020 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

internal enum Labels: String {
  case none = "None"
}

@available(iOS 11.0, *)
extension CocoImageAnnotation {
  public init(mask: [[Int8]], label: String) {
    self.init(
      bbox: nil,
      keypoints: [],
      segmentation: CocoImageAnnotation.Segmentation(mask: mask),
      label: label
    )
  }
}

@available(iOS 11.0, *)
extension Segmentation: AnnotationRepresentable {

  public func annotations(for input: FritzVisionImage) -> [CocoImageAnnotation] {
    if self.label == Labels.none.rawValue {return []}
    return [CocoImageAnnotation(mask: self.intMask, label: self.label)]
  }
}

@available(iOS 12.0, *)
extension FritzVisionSegmentationPredictor: PredictionImageRecordable {
  public typealias AnnotationRepresentation = [Segmentation]
}
