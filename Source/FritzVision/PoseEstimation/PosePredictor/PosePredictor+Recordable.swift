//
//  PosePredictor+Recordable.swift
//  FritzVision
//
//  Created by Christopher Kelly on 11/13/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

// MARK: - Pose Prediction Data Recording.

@available(iOS 11.0, *)
extension CocoImageAnnotation {

  /// Initialize with a `Pose`.
  public init<Skeleton: SkeletonType>(pose: Pose<Skeleton>) {
    var keypoints: [CocoImageAnnotation.Keypoint] = []

    for kp in Skeleton.allCases {
      if let keypoint = pose.getKeypoint(for: kp) {
        let formatted = CocoImageAnnotation.Keypoint(
          id: keypoint.part.rawValue,
          label: String(describing:keypoint.part),
          x: keypoint.position.x,
          y: keypoint.position.y,
          visibility: .labeledAndVisible
        )
        keypoints.append(formatted)
      }
    }
    self.init(bbox: nil, keypoints: keypoints, segmentation: nil, label: Skeleton.objectName)
  }
}

@available(iOS 11.0, *)
extension Pose: AnnotationRepresentable {


  /// Create annotations for pose resized to input image size.
  /// - Parameter input: Input image.
  public func annotations(for input: FritzVisionImage) -> [CocoImageAnnotation] {
    let scaledPose = scaled(to: input.size)
    return [
      CocoImageAnnotation(pose: scaledPose)
    ]
  }
}

@available(iOS 11.0, *)
extension FritzVisionPosePredictor: PredictionImageRecordable {
  public typealias AnnotationRepresentation = [Pose<Skeleton>]
}
