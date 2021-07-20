//
//  FritzVisionHumanPoseModelFast.swift
//  FritzVisionHumanPoseModelFast
//
//  Created by Christopher Kelly on 9/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

extension pose_mobilenet_353x257_5_8_large_1565381656: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionHumanPoseModelFast.modelConfig.identifier
  static var packagedModelVersion: Int = FritzVisionHumanPoseModelFast.modelConfig.version
  static var pinnedModelVersion: Int = 2
}

extension FritzVisionHumanPoseModelFast: PackagedModelType {
  
  public convenience init() {
    self.init(model: try! pose_mobilenet_353x257_5_8_large_1565381656(configuration: MLModelConfiguration()))
  }
}
