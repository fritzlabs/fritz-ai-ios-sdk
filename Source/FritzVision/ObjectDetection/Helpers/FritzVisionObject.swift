//
//  FritzVisionObject.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/8/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@objc(FritzVisionObject)
@available(iOS 11.0, *)
/// Object identified in object detection model. Contains the label and corresponding BoundingBox of identified model.
public class FritzVisionObject: NSObject, FritzPredictionResult {

  @objc public let detectedLabel: FritzVisionLabel

  /// BoundingBox of detected object.
  @objc public let boundingBox: BoundingBox

  public let bounds: CGSize

  @objc public var label: String {
    return self.detectedLabel.label
  }

  @objc public var confidence: Double {
    return self.detectedLabel.confidence
  }

  public override var description: String {
    return String(
      format: "(%@: %.2f [%.2f, %.2f, %.2f %.2f])",
      label,
      confidence,
      boundingBox.xMax,
      boundingBox.xMin,
      boundingBox.yMin,
      boundingBox.yMax
    )
  }

  /// Initialize detected object.
  /// - Parameters:
  ///   - label: Label
  ///   - boundingBox: Bounding box of object
  ///   - bounds: Range of prediction coordinates
  @objc(initWithLabel:boundingBox:bounds:)
  public init(label: FritzVisionLabel, boundingBox: BoundingBox, bounds: CGSize) {
    self.bounds = bounds
    self.detectedLabel = label
    self.boundingBox = boundingBox
  }

  public func scaled(to dimensions: CGSize) -> FritzVisionObject {
    let bbox = boundingBox.scaledBy(dimensions)

    return FritzVisionObject(
      label: detectedLabel,
      boundingBox: BoundingBox(from: bbox),
      bounds: dimensions
    )
  }
}
