//
//  MultiPoseModel.swift
//  FritzVision
//
//  Created by Christopher Kelly on 8/28/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public enum HumanSkeleton: Int, SkeletonType {

  public static let objectName = "person"

  case nose
  case leftEye
  case rightEye
  case leftEar
  case rightEar
  case leftShoulder
  case rightShoulder
  case leftElbow
  case rightElbow
  case leftWrist
  case rightWrist
  case leftHip
  case rightHip
  case leftKnee
  case rightKnee
  case leftAnkle
  case rightAnkle

  public static let connectedParts: [ConnectedPart<HumanSkeleton>] = [
    (.leftHip, .leftShoulder), (.leftElbow, .leftShoulder),
    (.leftElbow, .leftWrist), (.leftHip, .leftKnee),
    (.leftKnee, .leftAnkle), (.rightHip, .rightShoulder),
    (.rightElbow, .rightShoulder), (.rightElbow, .rightWrist),
    (.rightHip, .rightKnee), (.rightKnee, .rightAnkle),
    (.leftShoulder, .rightShoulder), (.leftHip, .rightHip),
  ]

  public static let poseChain: [ConnectedPart<HumanSkeleton>] = [
    (.nose, .leftEye), (.leftEye, .leftEar), (.nose, .rightEye),
    (.rightEye, .rightEar), (.nose, .leftShoulder),
    (.leftShoulder, .leftElbow), (.leftElbow, .leftWrist),
    (.leftShoulder, .leftHip), (.leftHip, .leftKnee),
    (.leftKnee, .leftAnkle), (.nose, .rightShoulder),
    (.rightShoulder, .rightElbow), (.rightElbow, .rightWrist),
    (.rightShoulder, .rightHip), (.rightHip, .rightKnee),
    (.rightKnee, .rightAnkle),
  ]
}

@available(iOS 11, *)
public typealias HumanPose = Pose<HumanSkeleton>
