//
//  FritzVisionStyleTests.swift
//  FritzVisionStyleTests
//
//  Created by Christopher Kelly on 8/6/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import FritzVisionHumanPoseModelFast
import XCTest

class FritzVisionMultiPoseModelTests: FritzTestCase {

  func testPredictMultiPoses() {
    let exp = XCTestExpectation(description: "The model runs")
    let model = FritzVisionHumanPoseModelFast()

    let image = TestImage.skiing.fritzImage
    model.predict(image) { (result, error) in
      guard let poseResult = result else { return }
      let poses = poseResult.poses(limit: 10)
      let img = image.draw(poses: poses)
      XCTAssertNil(error)
      XCTAssertNotNil(img)

      exp.fulfill()
    }
    wait(for: exp)
  }

}
