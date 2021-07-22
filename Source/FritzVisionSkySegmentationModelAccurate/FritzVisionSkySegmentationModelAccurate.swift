//
//  FritzVisionSkySegmentationModelAccurate.swift
//  FritzVisionSkySegmentationModelAccurate
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension sky_segmentation_mobilenet_512x512_75_1568486643: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionSkySegmentationModelAccurate.modelConfig
    .identifier
  static var packagedModelVersion: Int = FritzVisionSkySegmentationModelAccurate.modelConfig.version
  static var pinnedModelVersion: Int = 4
}

extension FritzVisionSkySegmentationModelAccurate: PackagedModelType {

  public convenience init() {
    self.init(model: try! sky_segmentation_mobilenet_512x512_75_1568486643(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionSkySegmentationModelAccurateObjc)
public class FritzVisionSkySegmentationModelAccurateObjc: NSObject {

  @objc public static var model: FritzVisionSkySegmentationModelAccurate {
    return FritzVisionSkySegmentationModelAccurate()
  }
}
