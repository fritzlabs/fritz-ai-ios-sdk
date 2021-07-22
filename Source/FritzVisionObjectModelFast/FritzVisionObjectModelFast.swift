//
//  FritzVisionObjectModelFast.swift
//  FritzVisionObjectModelFast
//
//  Created by Christopher Kelly on 10/1/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

@available(iOS 12.0, *)
extension MobileNetV2_SSDLite: SwiftIdentifiedModel {
  static let modelIdentifier = FritzVisionObjectModelFast.modelConfig.identifier
  static let packagedModelVersion = FritzVisionObjectModelFast.modelConfig.version
  static var pinnedModelVersion: Int = 1
}

@available(iOS 12.0, *)
extension FritzVisionObjectModelFast: PackagedModelType {

  public convenience init() {
    self.init(model: try! MobileNetV2_SSDLite(configuration: MLModelConfiguration()))
  }
}

@available(swift, obsoleted: 1.0)
@available(iOS 12.0, *)
@objc(FritzVisionObjectModelFastObjc)
public class FritzVisionObjectModelFastObjc: NSObject {

  @objc public static var model: FritzVisionObjectModelFast {
    return FritzVisionObjectModelFast()
  }
}
