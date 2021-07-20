//
//  MultiPoseSmoother.swift
//  FritzVision
//
//  Created by Christopher Kelly on 8/22/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
public class MultiPoseSmoother<Filter: PointFilterable, Skeleton: SkeletonType>
where Filter.T == CGPoint {

  private let logger = Logger(name: "MultiPoseSmoother")

  let poseMatcher = MultiPoseMatcher<Skeleton>(iouThreshold: 0.7)

  var smoothers = [Int: PoseSmoother<Filter, Skeleton>]()

  let smootherBuilder: () -> PoseSmoother<Filter, Skeleton>

  public init(numKeypoints: Int, options: Filter.SmoothingOptionsType) {
    smootherBuilder = { PoseSmoother<Filter, Skeleton>(options: options) }
  }

  /// Smoothe poses.
  ///
  /// - Parameter poses: List of poses to smooth.
  /// - Returns: Smoothed poses.
  public func smoothe(_ poses: [Pose<Skeleton>]) -> [Pose<Skeleton>] {
    let identifiedPoses = poseMatcher.update(with: poses)
    var smoothedPoses = [Pose<Skeleton>]()

    for (pose, id, _) in identifiedPoses {
      let smoother = smoothers[id] ?? smootherBuilder()

      smoothedPoses.append(smoother.smoothe(pose))

      if smoothers[id] == nil {
        smoothers[id] = smoother
      }
    }

    return smoothedPoses
  }
}

@available(iOS 11.0, *)
public typealias IdentifiedPose<Skeleton: SkeletonType> = (
  pose: Pose<Skeleton>, id: Int, lastIdentifiedAt: Date
)

@available(iOS 11.0, *)
public class MultiPoseMatcher<Skeleton: SkeletonType> {

  private let logger = Logger(name: "MultiPoseMatcher")

  /// List of currently identified poses.
  private(set) public var identifiedPoses = [Int: IdentifiedPose<Skeleton>]()

  /// List of poses to match new pose list to.
  public var poses: [Pose<Skeleton>] {
    return identifiedPoses.map({ $1.pose })
  }

  /// IOU Threshold required for a pose to be considered a match
  public let iouThreshold: Float

  /// Time interval to lookback when matching poses.  Any poses not matched that are older than
  /// this value will be removed.
  public let lookback: TimeInterval

  public init(iouThreshold: Float, lookback: TimeInterval = 2.0) {
    self.iouThreshold = iouThreshold
    self.lookback = lookback
  }

  private(set) public var poseCount = 0

  func match(pose: Pose<Skeleton>, to poses: [IdentifiedPose<Skeleton>]) -> IdentifiedPose<
    Skeleton
  >? {
    let rect = pose.boundingRect

    // Sorting poses by iou to match the given pose to the existing pose with the highest iou.
    let ious = poses.map { return (iou: IOU(rect, $0.pose.boundingRect), pose: $0) }
    let sortedIous = ious.sorted(by: { $0.iou > $1.iou })

    // Iterating through sorted IOUs, but if the first pose does not meet the IOU threshold, none
    // of the others will either, so just return.
    for (iou, pose) in sortedIous {
      if iou <= iouThreshold {
        return nil
      }
      return pose
    }
    return nil
  }

  /// Match list of poses
  public func match(poses: [Pose<Skeleton>]) -> [IdentifiedPose<Skeleton>?] {
    var remaining = self.identifiedPoses
    var matched = [IdentifiedPose<Skeleton>?]()

    for pose in poses {
      if let matchedPose = match(pose: pose, to: remaining.values.map { $0 }) {
        let matchedPose = remaining.removeValue(forKey: matchedPose.id)
        matched.append(matchedPose)
      } else {
        matched.append(nil)
      }
    }
    return matched
  }

  /// Update poses with new poses,
  public func update(
    with newPoses: [Pose<Skeleton>],
    having matches: [IdentifiedPose<Skeleton>?]? = nil
  ) -> [IdentifiedPose<Skeleton>] {
    let sortedPoses = newPoses.sorted(by: { $0.score > $1.score })
    let matchedPoses = matches ?? match(poses: sortedPoses)

    var updatedIdentifiedPoses = [Int: IdentifiedPose<Skeleton>]()
    // Update matched pose metadata
    for (i, matchedPose) in matchedPoses.enumerated() {
      if let match = matchedPose {
        logger.debug("Matched pose \(sortedPoses[i]) to \(match)")
        let identifiedPose = (pose: sortedPoses[i], id: match.id, lastIdentifiedAt: Date())
        updatedIdentifiedPoses[identifiedPose.id] = identifiedPose
      } else {
        let id = poseCount
        poseCount += 1
        let identifiedPose = (pose: sortedPoses[i], id: id, lastIdentifiedAt: Date())
        updatedIdentifiedPoses[id] = identifiedPose
      }
    }

    let nonMatchedIds = Set(identifiedPoses.keys).subtracting(Set(updatedIdentifiedPoses.keys))
    // Remove expired poses
    for id in nonMatchedIds {
      guard let existingPose = identifiedPoses[id] else { continue }
      if Date().timeIntervalSince(existingPose.lastIdentifiedAt) > lookback {
        let rect = existingPose.pose.boundingRect
        logger.debug("Removing pose \(existingPose.id) with center at \(rect.midX), \(rect.midY)")
        identifiedPoses.removeValue(forKey: id)
      }
    }

    for (id, identifiedPose) in updatedIdentifiedPoses {
      identifiedPoses[id] = identifiedPose
    }

    return updatedIdentifiedPoses.values.map { $0 }
  }
}
