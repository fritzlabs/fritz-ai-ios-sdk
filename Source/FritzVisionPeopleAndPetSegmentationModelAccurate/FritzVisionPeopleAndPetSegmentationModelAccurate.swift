//
//  FritzVisionPeopleAndPetSegmentationModelAccurate.swift
//  FritzVisionPeopleAndPetSegmentationModelAccurate
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension people_and_pet_segmentation_icnet_768x768_1_1572886302: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionPeopleAndPetSegmentationModelAccurate.modelConfig
    .identifier
  static var packagedModelVersion: Int = FritzVisionPeopleAndPetSegmentationModelAccurate
    .modelConfig.version
  static var pinnedModelVersion: Int = 2
}

extension FritzVisionPeopleAndPetSegmentationModelAccurate: PackagedModelType {

  public convenience init() {
    self.init(model: try! people_and_pet_segmentation_icnet_768x768_1_1572886302(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionPeopleAndPetSegmentationModelAccurateObjc)
public class FritzVisionPeopleAndPetSegmentationModelAccurateObjc: NSObject {

  @objc public static var model: FritzVisionPeopleAndPetSegmentationModelAccurate {
    return FritzVisionPeopleAndPetSegmentationModelAccurate()
  }
}
