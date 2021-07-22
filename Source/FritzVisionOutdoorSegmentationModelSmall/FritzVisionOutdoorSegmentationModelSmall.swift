//
//  FritzVisionOutdoorSegmentationModelSmall.swift
//  FritzVisionOutdoorSegmentationModelSmall
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension outdoor_segmentation_mobilenet_256x256_75_1568564460: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionOutdoorSegmentationModelSmall.modelConfig
    .identifier
  static var packagedModelVersion: Int = FritzVisionOutdoorSegmentationModelSmall.modelConfig
    .version
  static var pinnedModelVersion: Int = 2
}

extension FritzVisionOutdoorSegmentationModelSmall: PackagedModelType {
  
  public convenience init() {
    self.init(model: try! outdoor_segmentation_mobilenet_256x256_75_1568564460(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionOutdoorSegmentationModelSmallObjc)
public class FritzVisionOutdoorSegmentationModelSmallObjc: NSObject {
  
  @objc public static var model: FritzVisionOutdoorSegmentationModelSmall {
    return FritzVisionOutdoorSegmentationModelSmall()
  }
}
