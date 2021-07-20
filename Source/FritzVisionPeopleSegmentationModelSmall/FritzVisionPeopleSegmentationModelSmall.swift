//
//  FritzVisionPeopleSegmentationModelSmall.swift
//  FritzVisionPeopleSegmentationModelSmall
//
//  Created by Christopher Kelly on 9/24/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//
import Foundation

extension people_segmentation_mobilenet_256x256_75_1568565137: SwiftIdentifiedModel {
  
  static var modelIdentifier = FritzVisionPeopleSegmentationModelSmall.modelConfig.identifier
  static var packagedModelVersion = FritzVisionPeopleSegmentationModelSmall.modelConfig.version
  static var pinnedModelVersion = 2
}

/// Image segmentation model to detect people.
extension FritzVisionPeopleSegmentationModelSmall: PackagedModelType {

  public convenience init() {
    self.init(model: try! people_segmentation_mobilenet_256x256_75_1568565137(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionPeopleSegmentationModelSmallObjc)
public class FritzVisionPeopleSegmentationModelSmallObjc: NSObject {

  @objc public static var model: FritzVisionPeopleSegmentationModelSmall {
    return FritzVisionPeopleSegmentationModelSmall()
  }
}
