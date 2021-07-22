//
//  FritzVisionHairSegmentationModelFast.swift
//  FritzVisionHairSegmentationModelFast
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension hair_segmentation_mobilenet_256x256_5_1568558307: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionHairSegmentationModelFast.modelConfig.identifier
  static var packagedModelVersion: Int = FritzVisionHairSegmentationModelFast.modelConfig.version
  static var pinnedModelVersion: Int = 7
}

extension FritzVisionHairSegmentationModelFast: PackagedModelType {

  public convenience init() {
    self.init(model: try! hair_segmentation_mobilenet_256x256_5_1568558307(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionHairSegmentationModelFastObjc)
public class FritzVisionHairSegmentationModelFastObjc: NSObject {

  @objc public static var model: FritzVisionHairSegmentationModelFast {
    return FritzVisionHairSegmentationModelFast()
  }
}
