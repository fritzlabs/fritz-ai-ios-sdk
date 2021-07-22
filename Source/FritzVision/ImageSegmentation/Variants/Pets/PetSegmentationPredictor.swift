//
//  FritzVisionPetSegmentationModel.swift
//  FritzVisionPetSegmentationModel
//
//  Created by Christopher Kelly on 9/24/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@objc(FritzVisionPetClass)
public class FritzVisionPetClass: NSObject {
  @objc public static let none = ModelSegmentationClass(
    label: "None",
    index: 0,
    color: (0, 0, 0, 0)
  )
  @objc public static let pet = ModelSegmentationClass(
    label: "Pet",
    index: 1,
    color: (0, 128, 128, 255)
  )

  @objc public static let allClasses: [ModelSegmentationClass] = [
    FritzVisionPetClass.none,
    FritzVisionPetClass.pet,
  ].sorted(by: { $0.index < $1.index })
}

/// Image segmentation model to detect pets.
@available(iOS 11.0, *)
@objc(FritzVisionPetSegmentationPredictor)
public class FritzVisionPetSegmentationPredictor: FritzVisionSegmentationPredictor {

  /// Build Pet Segmentation Model with provided model.
  ///
  /// - Parameter model: Model to use
  @objc(initWithModel:)
  public convenience init(model: FritzMLModel) {
    self.init(model: model, classes: FritzVisionPetClass.allClasses)
  }

  /// Build Pet Segmentation Model with provided model.
  ///
  /// - Parameter model: Model to use
  @objc(initWithIdentifiedModel:)
  public convenience init(model: SwiftIdentifiedModel) {
    self.init(model: model, classes: FritzVisionPetClass.allClasses)
  }

  @objc(initWithModel:managedModel:)
  public convenience init(model: FritzMLModel, managedModel: FritzManagedModel) {
    self.init(
      model: model,
      classes: FritzVisionPetClass.allClasses,
      managedModel: managedModel
    )
  }

}
