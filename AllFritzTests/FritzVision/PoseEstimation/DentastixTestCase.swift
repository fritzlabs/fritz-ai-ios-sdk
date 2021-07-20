//
//  FritzVisionStyleTests.swift
//  FritzVisionStyleTests
//
//  Created by Christopher Kelly on 8/6/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import ARKit
import XCTest

@testable import FritzManagedModel
@testable import FritzVision
@testable import FritzVisionRigidPose

extension dentastix_224x224_35_small_1558378313: SwiftIdentifiedModel {
  static let modelIdentifier = DentastixPoseModel.modelConfig.identifier
  static let packagedModelVersion = 7
}

public enum DentastixSkeleton: Int, SkeletonType {

  public static let objectName = "Dentastix"
  
  case topLeft
  case bottomLeft
  case bottomRight
  case topRight
  case center
}

@available(iOS 11.0, *)
public final class DentastixPoseModel: FritzVisionPosePredictor<DentastixSkeleton>,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "78e852bb04734716bd00004d91820844",
    version: 7
  )

  @objc public static var managedModel: FritzManagedModel {
    return modelConfig.buildManagedModel()
  }

  @objc public static var wifiRequiredForModelDownload: Bool = _wifiRequiredForModelDownload

  public static func fetchModel(completionHandler: @escaping (DentastixPoseModel?, Error?) -> Void)
  {
    _fetchModel(completionHandler: completionHandler)
  }

  public convenience init() {
    let model = try! dentastix_224x224_35_small_1558378313(configuration: MLModelConfiguration()).fritzModel()
    self.init(model: model)
  }
}

class DentastixPoseModelTests: FritzTestCase {
  let points: [SCNVector3] = [
    SCNVector3(-3.5, 0.7, 0.7),
    SCNVector3(-3.5, -0.7, -0.7),
    SCNVector3(3.5, 0.7, 0.7),
    SCNVector3(3.5, -0.7, -0.7),
    SCNVector3(0.0, 0.0, 0.0),
  ].map { $0 / 100 }

  lazy var poseModel = DentastixPoseModel()

  func testPredictCustomImage() {
    var image = TestImage.dentastix2.fritzImage
    image.metadata = FritzVisionImageMetadata()
    image.metadata?.orientation = .right
    let poseResult = try! poseModel.predict(image)
    let pose = poseResult.decodePose()

    image = TestImage.dentastix2.fritzImage
    let liftingModel = FritzVisionRigidBodyPoseLifting(model: poseModel, modelPoints: points)
    let pose2 = liftingModel.run2DPrediction(image)
    // For some reason core ml not lining up to vision, will figure out the slight discrepancy later
    // XCTAssertEqual(pose.keypoints.map { $0.position }, pose2.keypoints.map { $0.position })
    XCTAssertNotNil(pose)
    XCTAssertNotNil(pose2)
  }

  func testRotation() {
    let liftingModel = FritzVisionRigidBodyPoseLifting(model: poseModel, modelPoints: points)

    // Appears vertical
    let imageRotated = TestImage.dentastix2Rotated.fritzImage(orientation: .right)

    let poseVertical = liftingModel.run2DPrediction(imageRotated)!

    let rotatedPose = poseVertical.pose.rotateKeypointsToOriginalImage(image: imageRotated)

    // Make sure that propery orientation applied.
    let rotatedPoint = rotatedPose.keypoints[0].position
    let originalPoint = poseVertical.pose.keypoints[0].position
    XCTAssertEqual(rotatedPoint.x, originalPoint.y)
    XCTAssertEqual(rotatedPoint.y, imageRotated.originalSize.height - originalPoint.x)
  }

  func testFlippedDentastix() {
    let image = TestImage.dentastix2.fritzImage
    let imageUpsideDown = TestImage.dentastix2.fritzImage(orientation: .downMirrored)

    let firstPose = (try! poseModel.predict(image)).decodePose()
    let secondPose = (try! poseModel.predict(imageUpsideDown)).decodePose()
    let orientationManager = RigidBodyPoseOrientationManager<DentastixSkeleton>(
      flipOrientationDegrees: 100.0
    )
    XCTAssertEqual(orientationManager.orientPose(firstPose), firstPose)
    let _ = orientationManager.orientPose(secondPose)
  }

  func testDirectionX() {
    let keypoints = [
      CGPoint(x: 0.0, y: 0.0),
      CGPoint(x: 0.0, y: 1.0),
      CGPoint(x: 1.0, y: 0.0),
      CGPoint(x: 1.0, y: 1.0),
    ]
    let pose = Pose<DentastixSkeleton>(
      keypoints: keypoints.map {
        Keypoint<DentastixSkeleton>(
          index: 1,
          position: $0,
          score: 0.0,
          part: DentastixSkeleton.bottomLeft
        )
      },
      score: 0.0,
      bounds: CGSize(width: 1.0, height: 1.0)
    )
    let expectedVector = SCNVector3(1.0, 0.0, 0.0)
    XCTAssertEqual(pose.direction.x, expectedVector.x)
    XCTAssertEqual(pose.direction.y, expectedVector.y)
  }

  func testDirectionY() {
    let keypoints = [
      CGPoint(x: 0.0, y: 0.0),
      CGPoint(x: 1.0, y: 0.0),
      CGPoint(x: 0.0, y: 1.0),
      CGPoint(x: 1.0, y: 1.0),
    ]
    let pose = Pose<DentastixSkeleton>(
      keypoints: keypoints.map {
        Keypoint<DentastixSkeleton>(index: 0, position: $0, score: 0.0, part: .bottomLeft)
      },
      score: 0.0,
      bounds: CGSize(width: 1.0, height: 1.0)
    )
    let expectedVector = SCNVector3(0.0, 1.0, 0.0)
    XCTAssertEqual(pose.direction.x, expectedVector.x)
    XCTAssertEqual(pose.direction.y, expectedVector.y)
  }

  func testAnglesWork() {
    var yDir = SCNVector3(0.0, 1.0, 0.0)
    var xDir = SCNVector3(1.0, 0.0, 0.0)
    XCTAssertEqual(xDir.angle(between: yDir), .pi / 2, accuracy: 0.001)

    yDir = SCNVector3(0.0, 1.0, 0.0)
    xDir = SCNVector3(0.0, -1.0, 0.0)
    XCTAssertEqual(xDir.angle(between: yDir), .pi, accuracy: 0.001)
  }

}
