//
//  FritzVisionLivingRoomSegmentationModelSmall.swift
//  FritzVisionLivingRoomSegmentationModelSmall
//
//  Created by Christopher Kelly on 9/23/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension living_room_segmentation_mobilenet_256x256_75_1568564398: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionLivingRoomSegmentationModelSmall.modelConfig
    .identifier
  static var packagedModelVersion: Int = FritzVisionLivingRoomSegmentationModelSmall.modelConfig
    .version
  static var pinnedModelVersion: Int = 2
}

extension FritzVisionLivingRoomSegmentationModelSmall: PackagedModelType {

  public convenience init() {
    self.init(model: try! living_room_segmentation_mobilenet_256x256_75_1568564398(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionLivingRoomSegmentationModelSmallObjc)
public class FritzVisionLivingRoomSegmentationModelSmallObjc: NSObject {

  @objc public static var model: FritzVisionLivingRoomSegmentationModelSmall {
    return FritzVisionLivingRoomSegmentationModelSmall()
  }
}
