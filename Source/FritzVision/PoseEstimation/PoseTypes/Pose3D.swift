//
//  Pose3D.swift
//  FritzVision
//
//  Created by Christopher Kelly on 8/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Detected pose with Keypoints and corresponding score.
@available(iOS 11.0, *)
public class Pose3D<Skeleton: SkeletonType> {

  /// List of keypoints on pose
  public let keypoints: [Keypoint3D<Skeleton>]

  /// Pose confidence score.
  public let score: Double

  /// Bounds of keypoint values.
  public let bounds: CGSize

  required public init(keypoints: [Keypoint3D<Skeleton>], score: Double, bounds: CGSize) {
    self.keypoints = keypoints
    self.score = score
    self.bounds = bounds
  }

  public func isEqual(_ object: Any?) -> Bool {
    if let object = object as? Pose3D {
      return self == object
    }
    return false
  }
}

@available(iOS 11.0, *)
public func == <Skeleton: SkeletonType>(lhs: Pose3D<Skeleton>, rhs: Pose3D<Skeleton>) -> Bool {
  let areEqual = lhs.keypoints == rhs.keypoints && lhs.score == rhs.score

  return areEqual
}
