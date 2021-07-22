//
//  FritzVisionSkySegmentationModel.swift
//  FritzVisionSkySegmentationModel
//
//  Created by Christopher Kelly on 10/5/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@objc(FritzVisionSkyClass)
public class FritzVisionSkyClass: NSObject {
  @objc public static let none = ModelSegmentationClass(
    label: "None",
    index: 0,
    color: (0, 0, 0, 0)
  )
  @objc public static let sky = ModelSegmentationClass(
    label: "Sky",
    index: 1,
    color: (0, 128, 128, 255)
  )

  @objc public static let allClasses: [ModelSegmentationClass] = [
    FritzVisionSkyClass.none,
    FritzVisionSkyClass.sky,
  ].sorted(by: { $0.index < $1.index })
}

/// Image segmentation model to detect the sky.
@available(iOS 11.0, *)
@objc(FritzVisionSkySegmentationPredictor)
public class FritzVisionSkySegmentationPredictor: FritzVisionSegmentationPredictor {

  @objc(initWithModel:)
  public convenience init(model: FritzMLModel) {
    self.init(model: model, classes: FritzVisionSkyClass.allClasses)
  }

  @objc(initWithIdentifiedModel:)
  public convenience init(model: SwiftIdentifiedModel) {
    self.init(model: model, classes: FritzVisionSkyClass.allClasses)
  }

  @objc(initWithModel:managedModel:)
  public convenience init(model: FritzMLModel, managedModel: FritzManagedModel) {
    self.init(
      model: model,
      classes: FritzVisionSkyClass.allClasses,
      managedModel: managedModel
    )
  }
}
