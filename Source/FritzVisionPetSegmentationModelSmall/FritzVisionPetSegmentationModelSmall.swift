//
//  FritzVisionPetSegmentationModelSmall.swift
//  FritzVisionPetSegmentationModelSmall
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension pet_segmentation_mobilenet_256x256_75_1568563916: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionPetSegmentationModelSmall.modelConfig.identifier
  static var packagedModelVersion: Int = FritzVisionPetSegmentationModelSmall.modelConfig.version
  static var pinnedModelVersion: Int = 2
}

extension FritzVisionPetSegmentationModelSmall: PackagedModelType {

  public convenience init() {
    self.init(model: try! pet_segmentation_mobilenet_256x256_75_1568563916(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionPetSegmentationModelSmallObjc)
public class FritzVisionPetSegmentationModelSmallObjc: NSObject {

  @objc public static var model: FritzVisionPetSegmentationModelSmall {
    return FritzVisionPetSegmentationModelSmall()
  }
}
