//
//  FritzVisionImage+Pose.swift
//  FritzVision
//
//  Created by Christopher Kelly on 8/9/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
extension FritzVisionImage {

  ///  Decode poses and draws on original UIImage.
  ///
  /// - Parameter poses: List of poses to draw on image.
  /// - Parameter partThreshold: Threshold for pose part to connect to rest of skeleton.
  /// - Parameter drawBoundingBox: If true, draws surrounding bounding box around skeleton
  /// - Parameter drawSkeleton: If true, draws skeleton for pose
  /// - Parameter lineWidth: Width of line used to draw keypoints and skeleton.
  /// - Returns: UIImage if poses detected.
  public func draw<Skeleton: SkeletonType>(
    poses: [Pose<Skeleton>],
    keypointsMeeting partThreshold: Double = 0.4,
    drawBoundingBox: Bool = false,
    drawSkeleton: Bool = true,
    lineWidth: CGFloat = 3.0
  ) -> UIImage? {
    let originalSize = size
    guard let rotatedBuffer = prepare(size: originalSize) else { return nil }

    let uiImage = UIImage(ciImage: CIImage(cvPixelBuffer: rotatedBuffer))

    // TODO: Fix up center crop detection.
    let areaSize = CGRect(x: 0, y: 0, width: originalSize.width, height: originalSize.height)

    UIGraphicsBeginImageContext(originalSize)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }

    uiImage.draw(in: areaSize)

    for pose in poses {
      let scaledPose = pose.scaled(to: originalSize)
      var segments: [CGPoint] = []
      context.setLineWidth(lineWidth)
      context.setStrokeColor(UIColor.red.cgColor)

      if drawBoundingBox {
        context.addRect(scaledPose.boundingRect)
      }

      for keypoint in scaledPose.keypoints where keypoint.score > partThreshold {
        let radius: CGFloat = lineWidth
        context.addArc(
          center: keypoint.position,
          radius: radius,
          startAngle: 0.0,
          endAngle: .pi * 2.0,
          clockwise: true
        )
        context.strokePath()
      }

      for (left, right) in Skeleton.getConnectedKeypoints(
        keypoints: scaledPose.keypoints,
        minConfidence: partThreshold
      ) {
        segments.append(left.position)
        segments.append(right.position)
      }

      if drawSkeleton {
        context.strokeLineSegments(between: segments)
      }
    }

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }

  /// Draw pose on image.
  /// - Parameter pose: Pose
  /// - Parameter partThreshold: Threshold for pose part to connect to rest of skeleton.
  /// - Parameter drawBoundingBox: If true, draws surrounding bounding box around skeleton
  /// - Parameter drawSkeleton: If true, draws skeleton for pose
  /// - Parameter lineWidth: Width of line used to draw keypoints and skeleton.
  /// - Returns: UIImage of pose drawn on image.
  public func draw<Skeleton: SkeletonType>(
    pose: Pose<Skeleton>,
    keypointsMeeting partThreshold: Double = 0.4,
    drawBoundingBox: Bool = false,
    drawSkeleton: Bool = true,
    lineWidth: CGFloat = 3.0

  ) -> UIImage? {
    return draw(
      poses: [pose],
      keypointsMeeting: partThreshold,
      drawBoundingBox: drawBoundingBox,
      drawSkeleton: drawSkeleton,
      lineWidth: lineWidth
    )
  }

}
