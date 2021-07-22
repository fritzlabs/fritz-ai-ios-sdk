//
//  CIImagePipelineTests.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 7/25/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import FritzVision
import XCTest

class CIImagePipelineTestCase: XCTestCase {
  let testAssets = TestAssets()

  func testMirroredImage() {
    let image = TestImage.cat.fritzImage
    let pipeline = CIImagePipeline(image.ciImage!)
    pipeline.orient(.upMirrored)
    let output = pipeline.render()
    XCTAssertNotNil(output)
  }

}
