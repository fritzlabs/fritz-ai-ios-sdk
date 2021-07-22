//
//  FritzVisionSkySegmentationModelFast.swift
//  FritzVisionSkySegmentationModelFast
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension sky_segmentation_mobilenet_256x256_75_1568558807: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionSkySegmentationModelFast.modelConfig.identifier
  static var packagedModelVersion: Int = FritzVisionSkySegmentationModelFast.modelConfig.version
  static var pinnedModelVersion: Int = 3
}

extension FritzVisionSkySegmentationModelFast: PackagedModelType {

  public convenience init() {
    self.init(model: try! sky_segmentation_mobilenet_256x256_75_1568558807(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionSkySegmentationModelFastObjc)
public class FritzVisionSkySegmentationModelFastObjc: NSObject {

  @objc public static var model: FritzVisionSkySegmentationModelFast {
    return FritzVisionSkySegmentationModelFast()
  }
}
