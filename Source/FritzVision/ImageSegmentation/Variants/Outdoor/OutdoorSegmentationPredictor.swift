//
//  FritzVisionOutdoorSegmentationModel.swift
//  FritzVisionOutdoorSegmentationModel
//
//  Created by Christopher Kelly on 10/5/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@objc(FritzVisionOutdoorClass)
public class FritzVisionOutdoorClass: NSObject {
  @objc public static let none = ModelSegmentationClass(
    label: "None",
    index: 0,
    color: (0, 0, 0, 0)
  )
  @objc public static let building = ModelSegmentationClass(
    label: "Building",
    index: 1,
    color: (60, 180, 75, 255)
  )
  @objc public static let sky = ModelSegmentationClass(
    label: "Sky",
    index: 2,
    color: (255, 225, 25, 255)
  )
  @objc public static let tree = ModelSegmentationClass(
    label: "Tree",
    index: 3,
    color: (0, 130, 200, 255)
  )
  @objc public static let sidewalk = ModelSegmentationClass(
    label: "Sidewalk",
    index: 4,
    color: (245, 130, 48, 255)
  )
  @objc public static let ground = ModelSegmentationClass(
    label: "Ground",
    index: 5,
    color: (145, 30, 180, 255)
  )
  @objc public static let car = ModelSegmentationClass(
    label: "Car",
    index: 6,
    color: (70, 240, 240, 255)
  )
  @objc public static let water = ModelSegmentationClass(
    label: "Water",
    index: 7,
    color: (240, 50, 230, 255)
  )
  @objc public static let house = ModelSegmentationClass(
    label: "House",
    index: 8,
    color: (210, 245, 60, 255)
  )
  @objc public static let fence = ModelSegmentationClass(
    label: "Fence",
    index: 9,
    color: (250, 190, 190, 255)
  )
  @objc public static let sign = ModelSegmentationClass(
    label: "Sign",
    index: 10,
    color: (0, 128, 128, 255)
  )
  @objc public static let skyscraper = ModelSegmentationClass(
    label: "Skyscraper",
    index: 11,
    color: (230, 190, 255, 255)
  )
  @objc public static let bridge = ModelSegmentationClass(
    label: "Bridge",
    index: 12,
    color: (170, 110, 40, 255)
  )
  @objc public static let river = ModelSegmentationClass(
    label: "River",
    index: 13,
    color: (255, 250, 200, 255)
  )
  @objc public static let bus = ModelSegmentationClass(
    label: "Bus",
    index: 14,
    color: (128, 0, 0, 255)
  )
  @objc public static let truck = ModelSegmentationClass(
    label: "Truck",
    index: 15,
    color: (170, 255, 195, 255)
  )
  @objc public static let van = ModelSegmentationClass(
    label: "Van",
    index: 16,
    color: (128, 128, 0, 255)
  )
  @objc public static let motorbike = ModelSegmentationClass(
    label: "Motorbike",
    index: 17,
    color: (255, 215, 180, 255)
  )
  @objc public static let bicycle = ModelSegmentationClass(
    label: "Bicycle",
    index: 18,
    color: (0, 0, 128, 255)
  )
  @objc public static let trafficLight = ModelSegmentationClass(
    label: "Traffic light",
    index: 19,
    color: (128, 128, 128, 255)
  )
  @objc public static let person = ModelSegmentationClass(
    label: "Person",
    index: 20,
    color: (255, 255, 255, 255)
  )

  @objc public static let allClasses: [ModelSegmentationClass] = [
    FritzVisionOutdoorClass.none,
    FritzVisionOutdoorClass.building,
    FritzVisionOutdoorClass.sky,
    FritzVisionOutdoorClass.tree,
    FritzVisionOutdoorClass.sidewalk,
    FritzVisionOutdoorClass.ground,
    FritzVisionOutdoorClass.car,
    FritzVisionOutdoorClass.water,
    FritzVisionOutdoorClass.house,
    FritzVisionOutdoorClass.fence,
    FritzVisionOutdoorClass.sign,
    FritzVisionOutdoorClass.skyscraper,
    FritzVisionOutdoorClass.bridge,
    FritzVisionOutdoorClass.river,
    FritzVisionOutdoorClass.bus,
    FritzVisionOutdoorClass.truck,
    FritzVisionOutdoorClass.van,
    FritzVisionOutdoorClass.motorbike,
    FritzVisionOutdoorClass.bicycle,
    FritzVisionOutdoorClass.trafficLight,
    FritzVisionOutdoorClass.person,
  ].sorted(by: { $0.index < $1.index })
}

/// Image segmentation model to detect common outdoor objects.
@available(iOS 11.0, *)
@objc(FritzVisionOutdoorSegmentationPredictor)
public class FritzVisionOutdoorSegmentationPredictor: FritzVisionSegmentationPredictor {

  @objc(initWithModel:)
  public convenience init(model: FritzMLModel) {
    self.init(model: model, classes: FritzVisionOutdoorClass.allClasses)
  }

  @objc(initWithIdentifiedModel:)
  public convenience init(model: SwiftIdentifiedModel) {
    self.init(model: model, classes: FritzVisionOutdoorClass.allClasses)
  }

  @objc(initWithModel:managedModel:)
  public convenience init(model: FritzMLModel, managedModel: FritzManagedModel) {
    self.init(
      model: model,
      classes: FritzVisionOutdoorClass.allClasses,
      managedModel: managedModel
    )
  }
}
