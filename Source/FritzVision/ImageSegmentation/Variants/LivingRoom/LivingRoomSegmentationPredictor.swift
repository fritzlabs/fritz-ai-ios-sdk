//
//  FritzVisionLivingRoomSegmentationModel.swift
//  FritzVisionLivingRoomSegmentationModel
//
//  Created by Christopher Kelly on 10/5/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@objc(FritzVisionLivingRoomClass)
public class FritzVisionLivingRoomClass: NSObject {
  @objc public static let none = ModelSegmentationClass(
    label: "None",
    index: 0,
    color: (0, 0, 0, 0)
  )
  @objc public static let chair = ModelSegmentationClass(
    label: "Chair",
    index: 1,
    color: (0, 128, 128, 255)
  )
  @objc public static let wall = ModelSegmentationClass(
    label: "Wall",
    index: 2,
    color: (0, 0, 128, 255)
  )
  @objc public static let coffeeTable = ModelSegmentationClass(
    label: "Coffee Table",
    index: 3,
    color: (230, 25, 75, 255)
  )
  @objc public static let ceiling = ModelSegmentationClass(
    label: "Ceiling",
    index: 4,
    color: (255, 215, 180, 255)
  )
  @objc public static let floor = ModelSegmentationClass(
    label: "Floor",
    index: 5,
    color: (245, 130, 48, 255)
  )
  @objc public static let bed = ModelSegmentationClass(
    label: "Bed",
    index: 6,
    color: (255, 255, 25, 255)
  )
  @objc public static let lamp = ModelSegmentationClass(
    label: "Lamp",
    index: 7,
    color: (210, 245, 60, 255)
  )
  @objc public static let sofa = ModelSegmentationClass(
    label: "Sofa, couch, lounge",
    index: 8,
    color: (70, 240, 240, 255)
  )
  @objc public static let windowpane = ModelSegmentationClass(
    label: "Windowpane",
    index: 9,
    color: (0, 130, 200, 255)
  )
  @objc public static let pillow = ModelSegmentationClass(
    label: "Pillow",
    index: 10,
    color: (145, 30, 180, 255)
  )

  @objc public static let allClasses: [ModelSegmentationClass] = [
    FritzVisionLivingRoomClass.none,
    FritzVisionLivingRoomClass.chair,
    FritzVisionLivingRoomClass.wall,
    FritzVisionLivingRoomClass.coffeeTable,
    FritzVisionLivingRoomClass.ceiling,
    FritzVisionLivingRoomClass.floor,
    FritzVisionLivingRoomClass.bed,
    FritzVisionLivingRoomClass.lamp,
    FritzVisionLivingRoomClass.sofa,
    FritzVisionLivingRoomClass.windowpane,
    FritzVisionLivingRoomClass.pillow,
  ].sorted(by: { $0.index < $1.index })
}

/// Image segmentation model to detect common outdoor objects.
@available(iOS 11.0, *)
@objc(FritzVisionLivingRoomSegmentationPredictor)
public class FritzVisionLivingRoomSegmentationPredictor: FritzVisionSegmentationPredictor {

  @objc(initWithModel:)
  public required init(model: FritzMLModel) {
    super.init(
      model: model,
      classes: FritzVisionLivingRoomClass.allClasses
    )
  }

  @objc(initWithIdentifiedModel:)
  public required init(model: SwiftIdentifiedModel) {
    super.init(
      model: model,
      classes: FritzVisionLivingRoomClass.allClasses
    )
  }

  @objc(initWithModel:managedModel:)
  public required init(model: FritzMLModel, managedModel: FritzManagedModel) {
    super.init(
      model: model,
      classes: FritzVisionLivingRoomClass.allClasses,
      managedModel: managedModel
    )
  }
}
