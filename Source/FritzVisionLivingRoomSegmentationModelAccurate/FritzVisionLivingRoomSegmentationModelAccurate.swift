//
//  FritzVisionLivingRoomSegmentationModelAccurate.swift
//  FritzVisionLivingRoomSegmentationModelAccurate
//
//  Created by Christopher Kelly on 9/23/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension living_room_segmentation_mobilenet_512x512_75_1568491493: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionLivingRoomSegmentationModelAccurate.modelConfig
    .identifier
  static var packagedModelVersion: Int = FritzVisionLivingRoomSegmentationModelAccurate.modelConfig
    .version
  static var pinnedModelVersion: Int = 4
}

extension FritzVisionLivingRoomSegmentationModelAccurate: PackagedModelType {

  public convenience init() {
    self.init(model: try! living_room_segmentation_mobilenet_512x512_75_1568491493(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionLivingRoomSegmentationModelAccurateObjc)
public class FritzVisionLivingRoomSegmentationModelAccurateObjc: NSObject {

  @objc public static var model: FritzVisionLivingRoomSegmentationModelAccurate {
    return FritzVisionLivingRoomSegmentationModelAccurate()
  }
}
