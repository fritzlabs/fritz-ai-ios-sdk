//
//  PoseSmoother.swift
//  FritzVision
//
//  Created by Christopher Kelly on 3/29/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
public class PoseSmoother<Filter: PointFilterable, Skeleton: SkeletonType>
where Filter.T == CGPoint {

  let filters: [Filter]

  public init(options: Filter.SmoothingOptionsType = Filter.SmoothingOptionsType()) {
    var filters = [Filter]()

    for _ in 0..<Skeleton.allCases.count {
      let filter = Filter(options: options)
      filters.append(filter)
    }
    self.filters = filters
  }

  public func smoothe(_ pose: Pose<Skeleton>) -> Pose<Skeleton> {
    var newKeypoints: [Keypoint<Skeleton>] = []

    for keypoint in pose.keypoints {
      let filter = filters[keypoint.index]

      let smoothed = filter.filter(keypoint.position)
      newKeypoints.append(keypoint.fromPosition(smoothed))
    }
    return Pose<Skeleton>(keypoints: newKeypoints, score: pose.score, bounds: pose.bounds)
  }
}

@available(iOS 11.0, *)
public class Pose3DSmoother<Filter: PointFilterable, Skeleton: SkeletonType>
where Filter.T == Point3D {

  let filters: [Filter]

  public init(options: Filter.SmoothingOptionsType) {
    var filters = [Filter]()
    for _ in 0..<Skeleton.allCases.count {
      let filter = Filter(options: options)
      filters.append(filter)
    }
    self.filters = filters
  }

  public func smoothe(_ pose: Pose3D<Skeleton>) -> Pose3D<Skeleton> {
    var newKeypoints: [Keypoint3D<Skeleton>] = []

    for keypoint in pose.keypoints {
      let filter = filters[keypoint.index]

      let smoothed = filter.filter(keypoint.position)
      newKeypoints.append(keypoint.fromPosition(smoothed))
    }
    return Pose3D<Skeleton>(keypoints: newKeypoints, score: pose.score, bounds: pose.bounds)
  }
}
