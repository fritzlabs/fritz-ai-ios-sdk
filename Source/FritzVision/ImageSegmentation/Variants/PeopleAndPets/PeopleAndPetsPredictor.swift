//
//  PeopleAndPetsPredictor.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Class labels for FritzVisionPeopleAndPetSegmentationMediumModel
@objc(FritzVisionPeopleAndPetSegmentationMediumClass)
public class FritzVisionPeopleAndPetClass: NSObject {
  @objc public static let none = ModelSegmentationClass(
    label: "None",
    index: 0,
    color: (0, 0, 0, 0)
  )
  @objc public static let petOrPerson = ModelSegmentationClass(
    label: "Pet or Person",
    index: 1,
    color: (0, 0, 0, 255)
  )

  @objc public static let allClasses: [ModelSegmentationClass] = [
    FritzVisionPeopleAndPetClass.none,
    FritzVisionPeopleAndPetClass.petOrPerson,
  ]
}

/// Image segmentation model to detect people and pets.
@available(iOS 11.0, *)
@objc(FritzVisionPeopleAndPetSegmentationMediumModel)
public class FritzVisionPeopleAndPetSegmentationPredictor: FritzVisionSegmentationPredictor {

  @objc(initWithModel:)
  public convenience init(model: FritzMLModel) {
    self.init(
      model: model,
      classes: FritzVisionPeopleAndPetClass.allClasses
    )
  }

  @objc(initWithIdentifiedModel:)
  public convenience init(model: SwiftIdentifiedModel) {
    self.init(
      model: model,
      classes: FritzVisionPeopleAndPetClass.allClasses
    )
  }

  @objc(initWithModel:managedModel:)
  public convenience init(model: FritzMLModel, managedModel: FritzManagedModel) {
    self.init(
      model: model,
      classes: FritzVisionPeopleAndPetClass.allClasses,
      managedModel: managedModel
    )
  }

}
