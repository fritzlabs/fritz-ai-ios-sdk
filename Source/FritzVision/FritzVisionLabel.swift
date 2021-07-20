//
//  FritzVisionLabel.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/8/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Represents a label for an image.
@objc(FritzVisionLabel)
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class FritzVisionLabel: NSObject, FritzPredictionResult {

  /// Human readable string of detected label.
  @objc public let label: String

  /// Prediction confidence for label in range of [0, 1]
  @objc public let confidence: Double

  public override var description: String {
    return String(format: "(%@: %.2f)", label, confidence)
  }

  @objc(initWithLabel:confidence:)
  public init(label: String, confidence: Double) {
    self.label = label
    self.confidence = confidence
    super.init()
  }
}
