//
//  FritzVisionSkySegmentationModelSmall.swift
//  FritzVisionSkySegmentationModelSmall
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension sky_segmentation_mobilenet_256x256_75_1568564280: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionSkySegmentationModelSmall.modelConfig.identifier
  static var packagedModelVersion: Int = FritzVisionSkySegmentationModelSmall.modelConfig.version
  static var pinnedModelVersion: Int = 2
}

extension FritzVisionSkySegmentationModelSmall: PackagedModelType {

  public convenience init() {
    self.init(model: try! sky_segmentation_mobilenet_256x256_75_1568564280(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionSkySegmentationModelSmallObjc)
public class FritzVisionSkySegmentationModelSmallObjc: NSObject {

  @objc public static var model: FritzVisionSkySegmentationModelSmall {
    return FritzVisionSkySegmentationModelSmall()
  }
}
