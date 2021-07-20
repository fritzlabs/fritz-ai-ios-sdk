//
//  CustomPose.swift
//  FritzVision
//
//  Created by Christopher Kelly on 5/21/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// MARK - Pose Transformations
@available(iOS 11.0, *)
extension Pose {

  public func applying(_ t: CGAffineTransform) -> Pose<Skeleton> {
    let newKeypoints = keypoints.map {
      $0.fromPosition($0.position.applying(t))
    }
    return Pose<Skeleton>(keypoints: newKeypoints, score: score, bounds: bounds.applying(t))
  }

  /// Rotates keypoints to match original image orientation.
  ///
  /// Note: Currently only works on .up and .right original image orientations.
  ///
  /// - Parameter image: FritzVisionImage
  /// - Returns: Pose with keypoints rotated.
  public func rotateKeypointsToOriginalImage(image: FritzVisionImage) -> Pose<Skeleton> {
    let originalRotation = image.metadata!.cgOrientation
    // no need to rotate points if predictions were not rotated.
    if originalRotation == .up {
      return self
    }

    if originalRotation == .right {

      let rotated = keypoints.map {
        $0.fromPosition(CGPoint(x: $0.position.y, y: image.originalSize.height - $0.position.x))
      }
      let newBounds = CGSize(width: bounds.height, height: bounds.width)
      return Pose<Skeleton>(keypoints: rotated, score: score, bounds: newBounds)
    }
    return self
  }
}
