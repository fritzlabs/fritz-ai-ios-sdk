//
//  PeopleSegmentationPredictor.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/10/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Class labels for FritzVisionPeoplePredictor
@objc(FritzVisionPeopleClass)
public class FritzVisionPeopleClass: NSObject {
  @objc public static let none = ModelSegmentationClass(
    label: "None",
    index: 0,
    color: (0, 0, 0, 0)
  )
  @objc public static let person = ModelSegmentationClass(
    label: "Person",
    index: 1,
    color: (0, 0, 0, 255)
  )

  @objc public static let allClasses: [ModelSegmentationClass] = [
    FritzVisionPeopleClass.none,
    FritzVisionPeopleClass.person,
  ]
}

/// Predictor that takes predicts pixels that are people
@available(iOS 11.0, *)
@objc(FritzVisionPeopleSegmentationPredictor)
open class FritzVisionPeopleSegmentationPredictor: FritzVisionSegmentationPredictor {

  @objc(initWithModel:)
  public convenience init(model: FritzMLModel) {
    self.init(model: model, classes: FritzVisionPeopleClass.allClasses)
  }


  @objc(initWithIdentifiedModel:)
  public convenience init(model: SwiftIdentifiedModel) {
    self.init(model: model, classes: FritzVisionPeopleClass.allClasses)
  }

  @objc(initWithModel:managedModel:)
  public convenience init(model: FritzMLModel, managedModel: FritzManagedModel) {
    self.init(
      model: model,
      classes: FritzVisionPeopleClass.allClasses,
      managedModel: managedModel
    )
  }

}
