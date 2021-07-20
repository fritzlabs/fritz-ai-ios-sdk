//
//  PoseLifting+ModelDebugKey.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/17/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public enum PoseLiftingDebugKey: String, RawRepresentable {
  case pose2DOutput = "pose_2d_output"
  case pose2DTranslated = "pose_2d_translated"
  case poseLiftingInput = "pose_lifting_input"
  case poseLiftingRawOutput = "pose_lifting_raw_output"
  case poseLiftingDenormalizedOutput = "pose_lifting_denormalized_output"
}
