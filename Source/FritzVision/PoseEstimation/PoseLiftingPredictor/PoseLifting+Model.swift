//
//  FritzVisionPoseModel.swift
//  FritzVision
//
//  Created by Christopher Kelly on 1/31/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import CoreML
import Foundation

@available(iOS 11.0, *)
extension Pose: FritzPredictionInput {}

/// Options for Pose Model.
@objcMembers
public final class PoseLiftingPredictorOptions: NSObject, FritzPredictorOptionType {

  /// Default Pose model options.
  @objc public static let defaults = PoseLiftingPredictorOptions()

  /// If true only uses CPU to run predictions.
  @objc public var useCPUOnly = true
}

@available(iOS 11.0, *)
extension Pose3D: FritzPredictionResult {}

/// Model used to create a 3D pose from 2D pose
@available(iOS 11.0, *)
public final class FritzVisionPoseLiftingModel: BasePredictor, CoreMLPredictor {

  var modelDebugOutput: ModelDebugOutput<PoseLiftingDebugKey>?

  func normalizePose(_ pose: Pose<HumanSkeleton>) -> [CGPoint]? {
    guard let hipCenter = pose.getHipCenter() else { return nil }
    var translatedPosePoints = [
      CGPoint(x: 0.0, y: 0.0),
    ]

    for (i, modelPart) in PosePreprocessing.modelInputPartOrder.enumerated() {
      guard let keypoint = pose.getKeypoint(for: modelPart) else {
        print("No keypoint for \(modelPart), not using this pose.")
        return nil
      }
      let translated = keypoint.position - hipCenter
      let normalized = (translated - PosePreprocessing.mean2d[i + 1])
        / PosePreprocessing.std2d[i + 1]
      translatedPosePoints.append(normalized)
    }

    return translatedPosePoints
  }

  func processCoreMLResult(
    results: MLFeatureProvider,
    input: Pose<HumanSkeleton>,
    options: PoseLiftingPredictorOptions
  ) -> Pose3D<HumanSkeleton>? {

    guard let output = results.first?.multiArrayValue else { return nil }

    let multiArray = MultiArray<Double>(output)
    var points: [Point3D] = []

    for i in 0..<PosePreprocessing.std3d.count {
      let point3D = Point3D(
        x: CGFloat(multiArray[i, 0]),
        y: CGFloat(multiArray[i, 1]),
        z: CGFloat(multiArray[i, 2])
      )
      points.append(point3D)
    }

    modelDebugOutput?[.poseLiftingRawOutput] = points.map { [$0.x, $0.y, $0.z] }

    var normalized: [Point3D] = []

    for (i, point) in points.enumerated() {
      normalized.append(point * PosePreprocessing.std3d[i] + PosePreprocessing.mean3d[i])
    }

    modelDebugOutput?[.poseLiftingDenormalizedOutput] = normalized.map { [$0.x, $0.y, $0.z] }

    var keypoints = [Keypoint3D<HumanSkeleton>]()

    for (i, point) in normalized.enumerated() {
      if i == 0 {
        continue
      }
      guard let keypoint = input.getKeypoint(for: PosePreprocessing.modelInputPartOrder[i - 1])
      else {
        continue
      }
      keypoints.append(keypoint.to3D().fromPosition(point))
    }

    return Pose3D(keypoints: keypoints, score: input.score, bounds: input.bounds)
  }

  func processCoreMLInput(_ input: Pose<HumanSkeleton>, options: PoseLiftingPredictorOptions)
    -> MLFeatureProvider?
  {

    guard let normalized = normalizePose(input),
      let rawInputs = input.getInputKeypoints(translate: false),
      let translated = input.getInputKeypoints()
    else { return nil }

    modelDebugOutput?[.pose2DTranslated] = translated.map { [$0.position.x, $0.position.y] }
    modelDebugOutput?[.pose2DOutput] = rawInputs.map { [$0.position.x, $0.position.y] }
    modelDebugOutput?[.poseLiftingInput] = normalized.map { [$0.x, $0.y] }

    guard
      let mlMultiArray = try? MLMultiArray(
        shape: [14, 1, 2],
        dataType: .double
      )
    else {
      return nil
    }

    for (index, point) in normalized.enumerated() {
      mlMultiArray[2 * index] = NSNumber(floatLiteral: Double(point.x))
      mlMultiArray[2 * index + 1] = NSNumber(floatLiteral: Double(point.y))
    }

    return poseLifterInput(keypoints2D: mlMultiArray)
  }

  func predictCoreML(
    _ input: Pose<HumanSkeleton>,
    options: PoseLiftingPredictorOptions,
    completion: (Pose3D<HumanSkeleton>?, Error?) -> Void
  ) {

    guard let poseInput = processCoreMLInput(input, options: options) else {
      completion(nil, FritzVisionError.errorProcessingImage)
      return
    }

    do {
      let predictionOptions = MLPredictionOptions()
      predictionOptions.usesCPUOnly = options.useCPUOnly

      let results = try model.prediction(from: poseInput, options: predictionOptions)
      let modelResults = processCoreMLResult(results: results, input: input, options: options)
      completion(modelResults, nil)
    } catch {
      completion(nil, error)
    }
  }
}

@available(iOS 11.0, *)
extension FritzVisionPoseLiftingModel {

  /// Predict poses from an inputPose
  ///
  /// - Parameters:
  ///   - input: Input pose to process.
  ///   - options: The options used to configure the pose results.
  ///   - completion: Handler to call back on the main thread with poses or error.
  public func predict(
    _ input: Pose<HumanSkeleton>,
    options: PoseLiftingPredictorOptions = .init(),
    completion: (Pose3D<HumanSkeleton>?, Error?) -> Void
  ) {
    predictCoreML(input, options: options, completion: completion)
  }

}

@available(iOS 11.0, *)
extension FritzVisionPoseLiftingModel {

  /// Predict poses from an inputPose and captures model debug output.
  ///
  /// - Parameters:
  ///   - input: Input pose to process.
  ///   - options: The options used to configure the pose results.
  ///   - debugOutput: Instance to record debug output with.
  ///   - completion: Handler to call back on the main thread with poses or error.
  func predict(
    _ input: Pose<HumanSkeleton>,
    debugOutput: ModelDebugOutput<PoseLiftingDebugKey>?,
    options: PoseLiftingPredictorOptions = .init()
  ) throws -> (Pose3D<HumanSkeleton>) {
    self.modelDebugOutput = debugOutput
    let results = try predict(input, options: options)
    modelDebugOutput?.write()
    return results
  }
}
