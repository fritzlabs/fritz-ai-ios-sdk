//
//  FritzVisionPeopleSegmentationModelFast.swift
//  FritzVisionPeopleSegmentationModelFast
//
//  Created by Christopher Kelly on 9/24/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//
import Foundation

extension people_segmentation_mobilenet_256x256_75_1568480498: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionPeopleSegmentationModelFast.modelConfig.identifier
  static var packagedModelVersion: Int = FritzVisionPeopleSegmentationModelFast.modelConfig.version
  static var pinnedModelVersion: Int = 3
}

/// Image segmentation model to detect people.
extension FritzVisionPeopleSegmentationModelFast: PackagedModelType {

  public convenience init() {
    self.init(model: try! people_segmentation_mobilenet_256x256_75_1568480498(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionPeopleSegmentationModelFastObjc)
public class FritzVisionPeopleSegmentationModelFastObjc: NSObject {

  @objc public static var model: FritzVisionPeopleSegmentationModelFast {
    return FritzVisionPeopleSegmentationModelFast()
  }
}
