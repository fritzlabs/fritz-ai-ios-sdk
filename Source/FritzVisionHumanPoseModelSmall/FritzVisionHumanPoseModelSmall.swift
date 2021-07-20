//
//  FritzVisionHumanPoseModelSmall.swift
//  FritzVisionHumanPoseModelSmall
//
//  Created by Christopher Kelly on 9/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//
import Foundation

extension human_pose_mobilenet_353x257_5_8_large_1569859486: SwiftIdentifiedModel {
  static var modelIdentifier: String = FritzVisionHumanPoseModelSmall.modelConfig.identifier
  static var packagedModelVersion: Int = FritzVisionHumanPoseModelSmall.modelConfig.version
  static var pinnedModelVersion: Int = 2
}

extension FritzVisionHumanPoseModelSmall: PackagedModelType {

  public convenience init() {
    self.init(model: try! human_pose_mobilenet_353x257_5_8_large_1569859486(configuration: MLModelConfiguration()))
  }
}
