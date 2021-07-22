//
//  FritzVisionHairSegmentationModelAccurate.swift
//  FritzVisionHairSegmentationModelAccurate
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension hair_segmentation_mobilenet_512x512_75_1568494387: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionHairSegmentationModelAccurate.modelConfig
    .identifier
  static var packagedModelVersion: Int = FritzVisionHairSegmentationModelAccurate.modelConfig
    .version
  static var pinnedModelVersion: Int = 4
}

extension FritzVisionHairSegmentationModelAccurate: PackagedModelType {

  public convenience init() {
    self.init(model: try! hair_segmentation_mobilenet_512x512_75_1568494387(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionHairSegmentationModelAccurateObjc)
public class FritzVisionHairSegmentationModelAccurateObjc: NSObject {

  @objc static var model: FritzVisionHairSegmentationModelAccurate {
    return FritzVisionHairSegmentationModelAccurate()
  }
}
