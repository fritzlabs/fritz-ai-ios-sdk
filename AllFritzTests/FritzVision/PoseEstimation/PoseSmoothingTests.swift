//
//  FritzVisionStyleTests.swift
//  FritzVisionStyleTests
//
//  Created by Christopher Kelly on 8/6/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzVision
import FritzVisionHumanPoseModelFast
import FritzVisionMultiPoseModel

class FritzVisionPoseSmoothingTestCase: FritzTestCase {

  lazy var poseModel = FritzVisionHumanPoseModelFast()
  lazy var liftingModel = FritzVisionPoseLiftingModel()

  func test2DSavGolSmoothingWorks() {
    let windowSize = 6

    let filterOptions = SavitzkyGolayFilter<CGPoint>.Options(
      leftScan: 3,
      rightScan: 3,
      polonomialOrder: 3
    )
    let smoother = PoseSmoother<SavitzkyGolayFilter<CGPoint>, HumanSkeleton>(options: filterOptions)

    let options = FritzVisionPoseModelOptions()
    options.minPartThreshold = 0.01
    options.minPoseThreshold = 0.01
    let image = TestImage.tennis.fritzImage
    let poseResult = try! poseModel.predict(image, options: options)
    let pose = poseResult.pose()!

    for _ in 0...windowSize {
      let smoothedPose = smoother.smoothe(pose)
      XCTAssertEqual(smoothedPose.keypoints, pose.keypoints)
    }

    let smoothedPose = smoother.smoothe(pose)
    XCTAssertNotEqual(smoothedPose.keypoints, pose.keypoints)
  }

  func testPose3DSavGolSmoothingWorks() {

    let windowSize = 6
    let smoother = Pose3DSmoother<SavitzkyGolayFilter<Point3D>, HumanSkeleton>(
      options: SavitzkyGolayFilter<Point3D>.Options(leftScan: 3, rightScan: 3, polonomialOrder: 3)
    )

    let options = FritzVisionPoseModelOptions()
    options.minPartThreshold = 0.01
    options.minPoseThreshold = 0.01
    let image = TestImage.tennis.fritzImage
    let poseResult = try! poseModel.predict(image, options: options)
    let pose = poseResult.pose()!
    let pose3D = try! liftingModel.predict(pose)

    for _ in 0...windowSize {
      let smoothedPose = smoother.smoothe(pose3D)
      XCTAssertEqual(smoothedPose.keypoints, pose3D.keypoints)
    }

    let smoothedPose = smoother.smoothe(pose3D)
    XCTAssertNotEqual(smoothedPose.keypoints, pose3D.keypoints)
  }

  func testOneEuro2D() {
    let smoother = PoseSmoother<OneEuroPointFilter, HumanSkeleton>()
    let image = TestImage.tennis.fritzImage
    let options = FritzVisionPoseModelOptions()
    options.minPartThreshold = 0.01
    options.minPoseThreshold = 0.01
    let poseResult = try! poseModel.predict(image, options: options)
    let pose = poseResult.pose()!
    let smoothedPose1 = smoother.smoothe(pose)
    let smoothedPose2 = smoother.smoothe(pose)

    XCTAssertEqual(smoothedPose1, pose)
    XCTAssertNotEqual(smoothedPose2, pose)
  }

  func testOneEuroSmoothingNaN() {
    let filter = OneEuroFilter()
    let now = Date()
    let _ = filter.filter(value: 1.0, timestamp: now)
    let output = filter.filter(value: 1.0, timestamp: now)
    XCTAssertEqual(1.0, output)
  }

  func testOneEuroSmoothingNaNValues() {
    let filter = OneEuroFilter()
    let now = Date()
    let value = filter.filter(value: Double.nan, timestamp: now)
    XCTAssertTrue(value.isNaN)
    let output = filter.filter(value: 1.0, timestamp: now)
    XCTAssertEqual(1.0, output)
  }

  func testOneEuroConvenienceInitializer() {
    let smoother = PoseSmoother<OneEuroPointFilter, HumanSkeleton>()
    let image = TestImage.tennis.fritzImage
    let options = FritzVisionPoseModelOptions()
    options.minPartThreshold = 0.01
    options.minPoseThreshold = 0.01
    let poseResult = try! poseModel.predict(image, options: options)
    let pose = poseResult.pose()!
    let smoothedPose1 = smoother.smoothe(pose)
    let smoothedPose2 = smoother.smoothe(pose)

    XCTAssertEqual(smoothedPose1, pose)
    XCTAssertNotEqual(smoothedPose2, pose)
  }
}
