//
//  FritzVisionPetSegmentationModelAccurate.swift
//  FritzVisionPetSegmentationModelAccurate
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension pet_segmentation_mobilenet_512x512_75_1568517893: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionPetSegmentationModelAccurate.modelConfig
    .identifier
  static var packagedModelVersion: Int = FritzVisionPetSegmentationModelAccurate.modelConfig.version
  static var pinnedModelVersion: Int = 4
}

extension FritzVisionPetSegmentationModelAccurate: PackagedModelType {

  public convenience init() {
    self.init(model: try! pet_segmentation_mobilenet_512x512_75_1568517893(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionPetSegmentationModelAccurateObjc)
public class FritzVisionPetSegmentationModelAccurateObjc: NSObject {

  @objc public static var model: FritzVisionPetSegmentationModelAccurate {
    return FritzVisionPetSegmentationModelAccurate()
  }
}
