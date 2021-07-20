//
//  RigidPoseOrientationManager.swift
//  FritzVisionRigidPose
//
//  Created by Christopher Kelly on 5/29/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import FritzVision

@available(iOS 11.0, *)
extension Pose {

  var direction: SCNVector3 {
    let k1 = keypoints[0].position
    let k2 = keypoints[1].position
    let k3 = keypoints[2].position
    let k4 = keypoints[3].position

    let leftMid = (k1 + k2) / 2
    let rightMid = (k3 + k4) / 2
    let direction = rightMid - leftMid
    return SCNVector3(direction.x, direction.y, 0.0)
  }
}

@available(iOS 11.0, *)
public class RigidBodyPoseOrientationManager<Skeleton: SkeletonType> {

  /// Degree threshold for flipping pose.  If the absolute value of the angle
  /// of the previous pose direction and current pose direction is greater than the
  /// threshold, the pose will be flipped.
  public internal(set) var flipOrientationDegrees: Double

  /// If true, `previousPose` flipped from its original orientation.
  public private(set) var previousPoseFlipped = false

  /// Previous pose after orientation applied.
  public private(set) var previousPose: Pose<Skeleton>?

  private let logger = Logger(name: "RigidPoseOrientationManager")

  /// Initialize RigidPoseOrientationManager
  ///
  /// - Parameter flipOrientationDegrees: Degree threshold for flipping orientation
  ///     of pose.
  public init(flipOrientationDegrees: Double) {
    self.flipOrientationDegrees = flipOrientationDegrees
  }

  /// Orient pose according to previous pose and current pose direction.
  ///
  /// The current `pose` is compared against the previously oriented pose.
  ///
  /// - Parameter pose: Custom pose to align with previous pose.
  /// - Returns: Oriented pose.
  public func orientPose(_ pose: Pose<Skeleton>) -> Pose<Skeleton> {
    guard let previousPose = previousPose else {
      self.previousPose = pose
      return pose
    }
    let angle = previousPose.direction.angle(between: pose.direction) * 180 / .pi
    if abs(Double(angle)) > flipOrientationDegrees {
      let keypoints = [
        // ordering keypoints so that the direction of the pose is flipped.
        pose.keypoints[2],
        pose.keypoints[3],
        pose.keypoints[0],
        pose.keypoints[1],
        pose.keypoints[4],
      ]

      let modifiedPose = Pose<Skeleton>(
        keypoints: keypoints,
        score: pose.score,
        bounds: pose.bounds
      )
      self.previousPose = modifiedPose
      return modifiedPose
    }

    self.previousPose = pose
    return pose
  }
}
