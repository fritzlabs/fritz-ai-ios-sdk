//
//  FritzVisionOutdoorSegmentationModelFast.swift
//  FritzVisionOutdoorSegmentationModelFast
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension outdoor_segmentation_mobilenet_256x256_75_1568520080: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionOutdoorSegmentationModelFast.modelConfig
    .identifier
  static var packagedModelVersion: Int = FritzVisionOutdoorSegmentationModelFast.modelConfig.version
  static var pinnedModelVersion: Int = 3
}

extension FritzVisionOutdoorSegmentationModelFast: PackagedModelType {

  public convenience init() {
    self.init(model: try! outdoor_segmentation_mobilenet_256x256_75_1568520080(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionOutdoorSegmentationModelFastObjc)
public class FritzVisionOutdoorSegmentationModelFastObjc: NSObject {

  @objc public static var model: FritzVisionOutdoorSegmentationModelFast {
    return FritzVisionOutdoorSegmentationModelFast()
  }
}
