//
//  FritzVisionPetSegmentationModelFast.swift
//  FritzVisionPetSegmentationModelFast
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//
import Foundation

extension pet_segmentation_mobilenet_256x256_75_1568479918: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionPetSegmentationModelFast.modelConfig.identifier
  static var packagedModelVersion: Int = FritzVisionPetSegmentationModelFast.modelConfig.version
  static var pinnedModelVersion: Int = 6
}

extension FritzVisionPetSegmentationModelFast: PackagedModelType {

  public convenience init() {
    self.init(model: try! pet_segmentation_mobilenet_256x256_75_1568479918(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionPetSegmentationModelFastObjc)
public class FritzVisionPetSegmentationModelFastObjc: NSObject {

  @objc public static var model: FritzVisionPetSegmentationModelFast {
    return FritzVisionPetSegmentationModelFast()
  }
}
