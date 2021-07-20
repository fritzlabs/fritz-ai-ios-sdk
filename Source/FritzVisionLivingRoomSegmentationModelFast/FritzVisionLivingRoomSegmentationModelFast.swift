//
//  FritzVisionLivingRoomSegmentationModelFast.swift
//  FritzVisionLivingRoomSegmentationModelFast
//
//  Created by Christopher Kelly on 9/23/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension living_room_segmentation_mobilenet_256x256_75_1568482613: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionLivingRoomSegmentationModelFast.modelConfig
    .identifier
  static var packagedModelVersion: Int = FritzVisionLivingRoomSegmentationModelFast.modelConfig
    .version
  static var pinnedModelVersion: Int = 5
}

extension FritzVisionLivingRoomSegmentationModelFast: PackagedModelType {

  public convenience init() {
    self.init(model: try! living_room_segmentation_mobilenet_256x256_75_1568482613(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionLivingRoomSegmentationModelFastObjc)
public class FritzVisionLivingRoomSegmentationModelFastObjc: NSObject {

  @objc public static var model: FritzVisionLivingRoomSegmentationModelFast {
    return FritzVisionLivingRoomSegmentationModelFast()
  }
}
