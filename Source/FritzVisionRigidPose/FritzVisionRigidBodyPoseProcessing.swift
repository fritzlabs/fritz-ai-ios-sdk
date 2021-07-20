//
//  FritzVisionRigidBodyPoseProcessing.swift
//  FritzVisionRigidPose
//
//  Created by Christopher Kelly on 5/21/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import ARKit
import Foundation
import FritzVision

public struct FritzSCNPose {
  /// Transformation matrix to place object in camera coordinates.
  public let scenekitCameraTransform: SCNMatrix4

  /// Axis-angle rotatation vector.
  public let rotationVector: SCNVector4

  /// Translation vector to place object.
  public let translationVector: SCNVector3

  public init(
    scenekitCameraTransform: SCNMatrix4,
    rotationVector: SCNVector4,
    translationVector: SCNVector3
  ) {
    self.scenekitCameraTransform = scenekitCameraTransform
    self.rotationVector = rotationVector
    self.translationVector = translationVector
  }
}

public class FritzVisionRigidBodyPoseLiftingOptions {

  /// Custom Pose Model Options
  public var modelOptions: FritzVisionPoseModelOptions = FritzVisionPoseModelOptions()

  /// Required number of keypoints meeting threshold for valid 2D pose result
  public var requiredKeypointsMeetingThreshold = 3

  /// Keypoint confidence score minimum needed for a keypoint to count towards
  /// `requiredKeypointsMeetingThreshold`.
  public var keypointThreshold = 0.6

  /// Indices of keypoints to exclude from 3D Pose.
  public var excludedKeypointIndices: [Int] = []

  /// Pose Smoothing Options
  public var smoothingOptions: OneEuroPointFilter.Options? {
    get {
      modelOptions.smoothingOptions
    }
    set {
      modelOptions.smoothingOptions = newValue
    }
  }

  /// Angle at which keypoints are reversed.  Helps prevent accidental rotations.
  public var orientationFlipAngleThreshold: Double?

  public init() {}

}

/// Runs 2D and 3D pose estimation for rigid bodies.
@available(iOS 11.0, *)
public class FritzVisionRigidBodyPoseLifting<Skeleton: SkeletonType> {
  public let poseModel: FritzVisionPosePredictor<Skeleton>

  public private(set) var orientationManager: RigidBodyPoseOrientationManager<Skeleton>?

  let modelPoints: [SCNVector3]

  public init(model: FritzVisionPosePredictor<Skeleton>, modelPoints: [SCNVector3]) {
    self.poseModel = model
    self.modelPoints = modelPoints
  }

  private func initializeFromOptions(_ options: FritzVisionRigidBodyPoseLiftingOptions) {

    if let flipThreshold = options.orientationFlipAngleThreshold {
      if let orientationManager = orientationManager {
        orientationManager.flipOrientationDegrees = flipThreshold
      } else {
        self.orientationManager
          = RigidBodyPoseOrientationManager(flipOrientationDegrees: flipThreshold)
      }
    }
  }

  /// Run 2D rigid body pose estimation on FritzVisionImage with given orientation.
  ///
  /// Applies orientation and smoothing adjustment on pose if parameters specified in options.
  ///
  /// - Parameters:
  ///   - image: FritzVisionImage to run 2D pose estimation on.
  ///   - options: Pose Lifting options
  /// - Returns: Modified pose and raw poseResult from 2D pose prediction.
  public func run2DPrediction(
    _ image: FritzVisionImage,
    options: FritzVisionRigidBodyPoseLiftingOptions = .init()
  ) -> (pose: Pose<Skeleton>, result: FritzVisionPoseResult<Skeleton>)? {

    initializeFromOptions(options)

    guard let poseResult = try? self.poseModel.predict(image, options: options.modelOptions)
      else { return nil }
    guard let pose = process2DResult(poseResult, options: options) else { return nil }

    return (pose: pose, result: poseResult)
  }

  /// Perform post-processing on 2D Pose.
  ///
  /// - Parameter poseResult: Result of pose prediction
  /// - Parameter options: Pose Lifting Options
  public func process2DResult(
    _ poseResult: FritzVisionPoseResult<Skeleton>,
    options: FritzVisionRigidBodyPoseLiftingOptions
  ) -> Pose<Skeleton>? {
    guard let pose = poseResult.pose() else { return nil }

    let filtered = pose.keypoints.filter { !options.excludedKeypointIndices.contains($0.index) }
    let pointsMeetingThreshold = filtered.filter { $0.score > options.keypointThreshold }.count

    // Filter pose with not enough points of a high confidence
    guard pointsMeetingThreshold >= options.requiredKeypointsMeetingThreshold else { return nil }

    guard let orientationManager = orientationManager else { return pose }

    return orientationManager.orientPose(pose)
  }

  /// Infer 3D Points from 2D pose. Currently only works in portrait orientation.
  ///
  /// - Parameters:
  ///   - pose: CustomPose result from 2D Rigid Pose Prediction.
  ///   - image: FritzVisionImage of current image.
  ///   - frame: Frame for current image.
  ///   - options: Options for Pose lifting.
  /// - Returns: FritzSCNPose object containing transforms necessary to place SCNNode in
  ///     SceneKit Camera Coordinates.
  public func infer3DPose(
    _ pose: Pose<Skeleton>,
    image: FritzVisionImage,
    frame: ARFrame,
    options: FritzVisionRigidBodyPoseLiftingOptions
  ) -> FritzSCNPose? {

    let originalSize = image.originalSize
    let excludedKeypoints = options.excludedKeypointIndices

    let rotatedPose = pose.rotateKeypointsToOriginalImage(image: image)

    let keypoints = rotatedPose.keypoints.filter { !excludedKeypoints.contains($0.index) }
    let keypointsOpenCVCoords: [[Double]] = keypoints.map {
      [
        Double($0.position.x - (originalSize.width / 2)),
        Double($0.position.y - (originalSize.height / 2))
      ]
    }

    var flattenedPoints = keypointsOpenCVCoords.flatMap { $0 }

    let includedModelPoints = modelPoints.enumerated().filter {
      !excludedKeypoints.contains($0.offset)
    }.map { $0.element }

    let dentastix3DOpenCV = includedModelPoints.map { [$0.x, -$0.y, -$0.z] }
    var flattened3DModelPoints = dentastix3DOpenCV.flatMap { $0 }.map { Double($0) }

    let fx = frame.camera.intrinsics[0][0]
    let numKeypoints = modelPoints.count - excludedKeypoints.count

    guard
      let poseResult = PoseUtils.estimate3DPose(
        fromPose: &flattenedPoints,
        numKeypoints: Int32(numKeypoints),
        modelPoints: &flattened3DModelPoints,
        focalLength: Double(fx),
        centerX: Double(0.0),
        centerY: Double(0.0)
      )
    else { return nil }

    return FritzSCNPose(
      scenekitCameraTransform: poseResult.scenekitCameraTransform,
      rotationVector: poseResult.rotationVector,
      translationVector: poseResult.translationVector
    )
  }
}
