//
//  Pose.swift
//  FritzVision
//
//  Created by Christopher Kelly on 3/29/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

extension CGSize {
  static func / (numerator: CGSize, denominator: CGSize) -> CGSize {
    return CGSize(
      width: numerator.width / denominator.width,
      height: numerator.height / denominator.height
    )
  }
}

/// Detected pose with Keypoints and corresponding score.
@available(iOS 11.0, *)
public class Pose<Skeleton: SkeletonType>: NSObject {

  public static func == (lhs: Pose<Skeleton>, rhs: Pose<Skeleton>) -> Bool {
    return lhs.isEqual(rhs)
  }

  /// List of keypoints on pose
  public let keypoints: [Keypoint<Skeleton>]

  /// Pose confidence score.
  public let score: Double

  /// Bounds of keypoint values.
  public let bounds: CGSize

  public required init(keypoints: [Keypoint<Skeleton>], score: Double, bounds: CGSize) {
    self.keypoints = keypoints
    self.score = score
    self.bounds = bounds
  }

  public override var description: String {
    let formattedScore = String(format: "%.3f", score)
    let rect = boundingRect
    let formattedRect = String(
      format: "((%.2f,%.2f),[%.2f,%.2f])",
      rect.minX,
      rect.minY,
      rect.width,
      rect.height
    )
    return "Pose(score: \(formattedScore), boundingRect: \(formattedRect))"
  }

  /// The bounding rectangle of the keypoints.
  public var boundingRect: CGRect {
    var minX = CGFloat.greatestFiniteMagnitude
    var minY = CGFloat.greatestFiniteMagnitude
    var maxX = CGFloat.leastNonzeroMagnitude
    var maxY = CGFloat.leastNonzeroMagnitude

    for keypoint in keypoints {
      minX = min(keypoint.position.x, minX)
      minY = min(keypoint.position.y, minY)
      maxX = max(keypoint.position.x, maxX)
      maxY = max(keypoint.position.y, maxY)
    }
    let origin = CGPoint(x: minX, y: minY)
    return CGRect(origin: origin, size: CGSize(width: maxX - minX, height: maxY - minY))

  }

  /// Scale pose coordinates to match target dimensions.  Use when transforming coordinate
  /// spaces.
  ///
  /// - Parameters:
  ///   - targetDimensions: Dimensions of coordinate space to scale keypoint positions to.
  ///
  /// - Returns: Pose with scaled keypoints.
  public func scaled(to targetDimensions: CGSize) -> Pose<Skeleton> {
    let scale = targetDimensions / bounds

    var keypoints: [Keypoint<Skeleton>] = []
    for keypoint in self.keypoints {

      let newPosition = keypoint.position * scale
      let newKeypoint = Keypoint(
        index: keypoint.index,
        position: newPosition,
        score: keypoint.score,
        part: keypoint.part
      )
      keypoints.append(newKeypoint)
    }

    return Pose<Skeleton>(
      keypoints: keypoints,
      score: score,
      bounds: targetDimensions
    )
  }

  public func getKeypoint(for part: Skeleton) -> Keypoint<Skeleton>? {
    return keypoints.filter { $0.part == part }.first
  }

  public func to3D() -> Pose3D<Skeleton> {
    let newKeypoints = keypoints.map { $0.to3D() }
    return Pose3D<Skeleton>(keypoints: newKeypoints, score: score, bounds: bounds)
  }

  public override func isEqual(_ object: Any?) -> Bool {
    if let object = object as? Pose<Skeleton> {
      let areEqual = keypoints == object.keypoints && score == object.score

      return areEqual
    }
    return false
  }
}
