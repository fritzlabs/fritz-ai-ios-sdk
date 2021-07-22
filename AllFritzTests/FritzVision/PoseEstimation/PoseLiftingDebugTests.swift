//
//  PoseLiftingDebugTests.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 4/17/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import FritzVisionHumanPoseModelFast
import FritzVisionMultiPoseModel
import XCTest

@testable import FritzVision

class PoseLiftingDebugTests: FritzTestCase {

  lazy var poseModel = FritzVisionHumanPoseModelFast()
  lazy var liftingModel = FritzVisionPoseLiftingModel()

}

// MARK - Pose Lifting Debug Tests

extension PoseLiftingDebugTests {
  func predict(_ image: FritzVisionImage) -> ModelDebugOutput<PoseLiftingDebugKey> {
    let options = FritzVisionPoseModelOptions()
    options.minPartThreshold = 0.2
    options.minPoseThreshold = 0.2
    let results = try! poseModel.predict(image, options: options)
    let pose = results.pose()!

    var debugOutput = ModelDebugOutput<PoseLiftingDebugKey>(prefix: "poselifting")
    debugOutput.image = image.draw(pose: pose)

    let _ = try! liftingModel.predict(pose, debugOutput: debugOutput)
    return debugOutput
  }

  func testPredictPoseLiftingModel() {
    let image = TestImage.skiing.fritzImage
    let debugOutput = predict(image)
    XCTAssertNotNil(debugOutput.toData())
  }
}
