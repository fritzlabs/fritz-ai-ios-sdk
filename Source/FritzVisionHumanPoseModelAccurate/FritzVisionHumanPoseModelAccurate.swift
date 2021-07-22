//
//  FritzVisionHumanPoseModelAccurate.swift
//  FritzVisionHumanPoseModelAccurate
//
//  Created by Christopher Kelly on 9/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension pose_mobilenet_tensorflow_js_513x385_1_8_large_1569858252: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionHumanPoseModelAccurate.modelConfig.identifier
  static var packagedModelVersion: Int = FritzVisionHumanPoseModelAccurate.modelConfig.version
  static var pinnedModelVersion: Int = 2
}

extension FritzVisionHumanPoseModelAccurate: PackagedModelType {

  public convenience init() {
    self.init(model: try! pose_mobilenet_tensorflow_js_513x385_1_8_large_1569858252(configuration: MLModelConfiguration()))
  }
}
