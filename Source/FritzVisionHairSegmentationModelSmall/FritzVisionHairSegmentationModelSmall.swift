//
//  FritzVisionHairSegmentationModelSmall.swift
//  FritzVisionHairSegmentationModelSmall
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension hair_segmentation_mobilenet_256x256_5_1568564884: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionHairSegmentationModelSmall.modelConfig.identifier
  static var packagedModelVersion: Int = FritzVisionHairSegmentationModelSmall.modelConfig.version
  static var pinnedModelVersion: Int = 2
}

extension FritzVisionHairSegmentationModelSmall: PackagedModelType {

  public convenience init() {
    self.init(model: try! hair_segmentation_mobilenet_256x256_5_1568564884(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionHairSegmentationModelSmallObjc)
public class FritzVisionHairSegmentationModelSmallObjc: NSObject {

  @objc public static var model: FritzVisionHairSegmentationModelSmall {
    return FritzVisionHairSegmentationModelSmall()
  }
}
