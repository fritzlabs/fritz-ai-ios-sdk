//
//  FritzVisionOutdoorSegmentationModelAccurate.swift
//  FritzVisionOutdoorSegmentationModelAccurate
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension outdoor_segmentation_mobilenet_512x512_75_1568560755: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionOutdoorSegmentationModelAccurate.modelConfig
    .identifier
  static var packagedModelVersion: Int = FritzVisionOutdoorSegmentationModelAccurate.modelConfig
    .version
  static var pinnedModelVersion: Int = 3
}

extension FritzVisionOutdoorSegmentationModelAccurate: PackagedModelType {

  public convenience init() {
    self.init(model: try! outdoor_segmentation_mobilenet_512x512_75_1568560755(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionOutdoorSegmentationModelAccurateObjc)
public class FritzVisionOutdoorSegmentationModelAccurateObjc: NSObject {

  @objc public static var model: FritzVisionOutdoorSegmentationModelAccurate {
    return FritzVisionOutdoorSegmentationModelAccurate()
  }
}
