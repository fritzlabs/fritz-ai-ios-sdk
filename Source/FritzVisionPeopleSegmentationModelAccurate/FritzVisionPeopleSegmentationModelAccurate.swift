//
//  FritzVisionPeopleSegmentationModelAccurate.swift
//  FritzVisionPeopleSegmentationModelAccurate
//
//  Created by Christopher Kelly on 9/24/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Shim class so that loading the model uses the correct package.

extension people_segmentation_icnetV2_768x768: SwiftIdentifiedModel {
  static var modelIdentifier = FritzVisionPeopleSegmentationModelAccurate.modelConfig.identifier
  static var packagedModelVersion = FritzVisionPeopleSegmentationModelAccurate.modelConfig.version
  static var pinnedModelVersion = 2
}

/// Image segmentation model to detect people.
extension FritzVisionPeopleSegmentationModelAccurate: PackagedModelType {

  public convenience init() {
    self.init(model: try! people_segmentation_icnetV2_768x768(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionPeopleSegmentationModelAccurateObjc)
public class FritzVisionPeopleSegmentationModelAccurateObjc: NSObject {

  @objc public static var model: FritzVisionPeopleSegmentationModelAccurate {
    return FritzVisionPeopleSegmentationModelAccurate()
  }
}
