//
//  MultiPoseSmoothingTests.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 8/22/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import XCTest

@testable import FritzVision

class MultiPoseSmoothingTestCase: FritzTestCase {

  func buildPose(minX: CGFloat, width: CGFloat, bounds: CGSize = CGSize(width: 1.0, height: 1.0))
    -> Pose<HumanSkeleton>
  {
    let rect = CGRect(origin: CGPoint(x: minX, y: 0.0), size: CGSize(width: width, height: 1.0))

    let points = [
      CGPoint(x: rect.minX, y: rect.minY),
      CGPoint(x: rect.minX, y: rect.maxY),
      CGPoint(x: rect.maxX, y: rect.minY),
      CGPoint(x: rect.maxX, y: rect.maxY),
    ]
    let keypoints = points.enumerated().map {
      Keypoint<HumanSkeleton>(index: $0.offset, position: $0.element, score: 0.85, part: .leftAnkle)
    }
    return Pose(keypoints: keypoints, score: 0.5, bounds: bounds)
  }

  // Build pose
  func buildPose(origin: CGPoint, size: CGSize, bounds: CGSize = CGSize(width: 1.0, height: 1.0))
    -> Pose<HumanSkeleton>
  {
    let rect = CGRect(origin: origin, size: size)

    let points = [
      CGPoint(x: rect.minX, y: rect.minY),
      CGPoint(x: rect.minX, y: rect.maxY),
      CGPoint(x: rect.maxX, y: rect.minY),
      CGPoint(x: rect.maxX, y: rect.maxY),
    ]
    let keypoints = points.enumerated().map {
      Keypoint<HumanSkeleton>(index: $0.offset, position: $0.element, score: 0.85, part: .leftAnkle)
    }
    return Pose(keypoints: keypoints, score: 0.5, bounds: bounds)
  }

  func testAddsPoses() {
    let matcher = MultiPoseMatcher<HumanSkeleton>(iouThreshold: 0.9)
    let poses = [
      buildPose(origin: .zero, size: CGSize(width: 0.4, height: 1.0)),
      buildPose(origin: CGPoint(x: 0.5, y: 0.0), size: CGSize(width: 0.4, height: 1.0)),
    ]

    var results = matcher.update(with: poses)
    XCTAssertEqual(2, results.count)
    results = matcher.update(with: poses)

    XCTAssertEqual(Set([0, 1]), Set(results.map { $0.id }))
    XCTAssertEqual(Set(poses), Set(matcher.poses))
  }

  func testChoosesSamePosesOverAndOver() {
    let matcher = MultiPoseMatcher<HumanSkeleton>(iouThreshold: 0.9)
    let poses = [
      buildPose(origin: .zero, size: CGSize(width: 0.4, height: 1.0)),
      buildPose(origin: CGPoint(x: 0.5, y: 0.0), size: CGSize(width: 0.4, height: 1.0)),
    ]

    let _ = matcher.update(with: poses)
    let pose0ID = matcher.match(pose: poses[0], to: matcher.identifiedPoses.values.map { $0 })!.id
    let pose1ID = matcher.match(pose: poses[1], to: matcher.identifiedPoses.values.map { $0 })!.id

    for _ in 0...5 {
      let newPoses = poses.shuffled()
      let _ = matcher.update(with: newPoses)
      var results = matcher.match(pose: poses[0], to: matcher.identifiedPoses.values.map { $0 })
      XCTAssertEqual(results!.id, pose0ID)
      results = matcher.match(pose: poses[1], to: matcher.identifiedPoses.values.map { $0 })
      XCTAssertEqual(results!.id, pose1ID)
    }
  }

  func testAddsPosesWithExistingPoses() {
    // Any overlap should cause a match
    let matcher = MultiPoseMatcher<HumanSkeleton>(iouThreshold: 0.0)
    let poses = [
      buildPose(origin: .zero, size: CGSize(width: 0.2, height: 1.0)),
      buildPose(origin: CGPoint(x: 0.2, y: 0.0), size: CGSize(width: 0.2, height: 1.0)),
    ]

    let _ = matcher.update(with: poses)
    let poses2 = [
      buildPose(origin: CGPoint(x: 0.6, y: 0.0), size: CGSize(width: 0.2, height: 1.0)),
      buildPose(origin: CGPoint(x: 0.4, y: 0.0), size: CGSize(width: 0.2, height: 1.0)),
    ]

    // Since the IOU threshold is so high, the previous poses will not be matched! previous poses
    // are just the new poses
    let _ = matcher.update(with: poses2)
    XCTAssertEqual(Set([poses[0], poses[1], poses2[0], poses2[1]]), Set(matcher.poses))

  }

  func testFindsMatchesProperly() {

    // Any overlap should cause a match
    let matcher = MultiPoseMatcher<HumanSkeleton>(iouThreshold: 0.5)
    let poses = [
      buildPose(minX: 0.0, width: 0.2),
      buildPose(minX: 0.2, width: 0.2),
    ]
    let _ = matcher.update(with: poses)
    let poses2 = [
      buildPose(minX: 0.24, width: 0.2),
      buildPose(minX: 0.5, width: 0.2),
    ]

    let results = matcher.match(poses: poses2)
    XCTAssertNil(results[1])
    XCTAssertNotNil(results[0])

    // Since the IOU threshold is so high, the previous poses will not be matched! previous poses
    // are just the new poses
    let _ = matcher.update(with: poses2, having: results)
    let expected = [
      poses[0], poses2[0], poses2[1],
    ]
    XCTAssertEqual(Set(expected), Set(matcher.poses))
    XCTAssertEqual(matcher.poseCount, 3)
  }

}
