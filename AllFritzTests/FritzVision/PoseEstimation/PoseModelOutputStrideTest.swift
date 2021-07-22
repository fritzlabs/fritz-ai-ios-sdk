//
//  PoseModelOutputStrideTest.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 10/22/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import XCTest

@testable import FritzVision

extension dentastix_v2_pose_mobilenet_260x200_35_8_large_1571766563: SwiftIdentifiedModel {
  static let modelIdentifier = DentastixPoseModel.modelConfig.identifier
  static let packagedModelVersion = 1
}

extension dentastix_v2_pose_mobilenet_260x200_35_16_large_1571766544: SwiftIdentifiedModel {
  static let modelIdentifier = DentastixPoseModel.modelConfig.identifier
  static let packagedModelVersion = 1

}

class PosePredictorOutputStrideTestCase: FritzTestCase {

  func testOutputStrideDecodedProperly() {
    let stride8MLModel = try! dentastix_v2_pose_mobilenet_260x200_35_8_large_1571766563(configuration: MLModelConfiguration()).fritzModel()
    let outputStride8 = FritzVisionPosePredictor<DentastixSkeleton>(
      model: stride8MLModel
    )
    XCTAssertEqual(8, outputStride8.outputStride)

    let stride16MLModel = try! dentastix_v2_pose_mobilenet_260x200_35_16_large_1571766544(configuration: MLModelConfiguration()).fritzModel()
    let outputStride16 = FritzVisionPosePredictor<DentastixSkeleton>(
      model: stride16MLModel
    )
    XCTAssertEqual(16, outputStride16.outputStride)

    let noOutputStrideInDefinition = try! dentastix_224x224_35_small_1558378313(configuration: MLModelConfiguration()).fritzModel()
    let outputStrideNotSpecified = FritzVisionPosePredictor<DentastixSkeleton>(
      model: noOutputStrideInDefinition
    )
    XCTAssertEqual(8, outputStrideNotSpecified.outputStride)

  }
}
