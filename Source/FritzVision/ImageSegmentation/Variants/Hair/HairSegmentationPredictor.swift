//
//  HairSegmentationPredictor.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/10/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Class labels for FritzVisionHairPredictor
@objc(FritzVisionHairClass)
public class FritzVisionHairClass: NSObject {
  @objc public static let none = ModelSegmentationClass(
    label: "None",
    index: 0,
    color: (0, 0, 0, 0)
  )
  @objc public static let hair = ModelSegmentationClass(
    label: "Hair",
    index: 1,
    color: (0, 0, 0, 255)
  )

  @objc public static let allClasses: [ModelSegmentationClass] = [
    FritzVisionHairClass.none,
    FritzVisionHairClass.hair,
  ]
}

/// Predictor that takes predicts pixels that are Hair
@available(iOS 11.0, *)
@objc(FritzVisionHairSegmentationPredictor)
open class FritzVisionHairSegmentationPredictor: FritzVisionSegmentationPredictor {

  @objc(initWithModel:)
  public convenience init(model: FritzMLModel) {
    self.init(model: model, classes: FritzVisionHairClass.allClasses)
  }

  @objc(initWithIdentifiedModel:)
  public convenience init(model: SwiftIdentifiedModel) {
    self.init(model: model, classes: FritzVisionHairClass.allClasses)
  }

  @objc(initWithModel:managedModel:)
  public convenience init(model: FritzMLModel, managedModel: FritzManagedModel) {
    self.init(
      model: model,
      classes: FritzVisionHairClass.allClasses,
      managedModel: managedModel
    )
  }

}
