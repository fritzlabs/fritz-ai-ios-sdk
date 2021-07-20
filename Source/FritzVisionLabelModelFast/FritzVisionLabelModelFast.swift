//
//  FritzVisionLabelModelFast.swift
//  FritzVisionLabelModelFast
//
//  Created by Christopher Kelly on 9/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension imagenet_labeling_mobilenetv2_224x224_5_1568923397: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionLabelModelFast.modelConfig.identifier
  static var packagedModelVersion: Int = FritzVisionLabelModelFast.modelConfig.version
  static var pinnedModelVersion: Int = 3
}

extension FritzVisionLabelModelFast: PackagedModelType {

  public convenience init() {
    self.init(model: try! imagenet_labeling_mobilenetv2_224x224_5_1568923397(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionLabelModelFastObjc)
public class FritzVisionLabelModelFastObjc: NSObject {

  @objc public static var model: FritzVisionLabelModelFast {
    return FritzVisionLabelModelFast()
  }
}
