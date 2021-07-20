//
//  FritzVisionStyleTests.swift
//  FritzVisionStyleTests
//
//  Created by Christopher Kelly on 8/6/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import FritzVisionHumanPoseModelFast
import FritzVisionMultiPoseModel
import XCTest

@testable import FritzManagedModel
@testable import FritzVision

class FritzVisionPoseModelTests: FritzTestCase {

  lazy var poseModel = FritzVisionHumanPoseModelFast()

  // lazy var liftingModel = FritzVisionPoseLiftingModel()

  func testPredictCustomImage() {
    let image = TestImage.skiing.fritzImage
    let options = FritzVisionPoseModelOptions()
    let poseResult = try! poseModel.predict(image, options: options)
    let pose = poseResult.pose()!
    let img = image.draw(pose: pose)
    XCTAssertNotNil(img)
  }

  func testDecodeMultiplePoses() {
    let image = TestImage.family.fritzImage
    let options = FritzVisionPoseModelOptions()
    let poseResult = try! poseModel.predict(image, options: options)
    let poses = poseResult.poses(limit: 2)
    XCTAssertEqual(poses.count, 2)
    let img = image.draw(poses: poses)
    XCTAssertNotNil(img)
  }

  func testVisionAndCoreMLResultsMatch() {
    let image = TestImage.skiing.fritzImage
    let options = FritzVisionPoseModelOptions()
    options.smoothingOptions = nil
    options.forceCoreMLPrediction = false
    let poseResult = try! poseModel.predict(image, options: options)
    let pose = poseResult.pose()

    options.forceCoreMLPrediction = true
    let poseResult2 = try! poseModel.predict(image, options: options)
    let pose2 = poseResult2.pose()

    XCTAssertEqual(pose, pose2)
  }

  func testPoseResizing() {
    let image = TestImage.person.fritzImage
    let options = FritzVisionPoseModelOptions()
    options.minPartThreshold = 0.01
    options.minPoseThreshold = 0.01
    let result = try! poseModel.predict(image, options: options)

    let pose = result.pose()!

    var leftElbow = pose.getKeypoint(for: .leftElbow)!
    let _ = image.draw(pose: pose, keypointsMeeting: 0.01)
    let expected = CGPoint(x: 0.7383937761477459, y: 0.7316090364969486)

    XCTAssertLessThan(leftElbow.position.x - expected.x, 0.0001)
    XCTAssertLessThan(leftElbow.position.y - expected.y, 0.0001)

    // Double checking that scaling works as expected.
    let pose2 = result.pose()!
    leftElbow = pose2.scaled(to: image.size).getKeypoint(for: .leftElbow)!

    XCTAssertEqual(leftElbow.position.x, expected.x * image.size.width, accuracy: 2.0)
    XCTAssertEqual(leftElbow.position.y, expected.y * image.size.height, accuracy: 2.0)
  }

  func testPoseReturnsSaneResults() {
    let image = TestImage.jumpingJacks.fritzImage

    let options = FritzVisionPoseModelOptions()
    options.minPartThreshold = 0.5
    options.minPoseThreshold = 0.5
    let result = try! poseModel.predict(image, options: options)
    let poses = result.poses()
    XCTAssertEqual(poses.count, 2)

    // Manually determined keypoints positions.
    let expected: [CGPoint] = [
      CGPoint(x: 0.26, y: 0.25),
      CGPoint(x: 0.28, y: 0.24),
      CGPoint(x: 0.25, y: 0.24),
      CGPoint(x: 0.30, y: 0.25),
      CGPoint(x: 0.22, y: 0.25),
      CGPoint(x: 0.34, y: 0.36),
      CGPoint(x: 0.18, y: 0.36),
      CGPoint(x: 0.35, y: 0.46),
      CGPoint(x: 0.18, y: 0.46),
      CGPoint(x: 0.38, y: 0.56),
      CGPoint(x: 0.21, y: 0.53),
      CGPoint(x: 0.31, y: 0.56),
      CGPoint(x: 0.21, y: 0.55),
      CGPoint(x: 0.30, y: 0.74),
      CGPoint(x: 0.23, y: 0.74),
      CGPoint(x: 0.30, y: 0.90),
      CGPoint(x: 0.225, y: 0.89),
    ]

    for (i, keypoint) in poses[0].keypoints.enumerated() {
      XCTAssertEqual(keypoint.position.x, expected[i].x, accuracy: 0.02)
      XCTAssertEqual(keypoint.position.y, expected[i].y, accuracy: 0.01)
    }
  }
}
