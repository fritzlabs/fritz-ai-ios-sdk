//
//  HairSegmentationTests.swift
//  AllFritzTests
//
//  Created by Eric Hsiao on 4/12/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import FritzVisionHairSegmentationModelFast
import XCTest

@testable import FritzVision

class FritzVisionHairSegmentationModelTests: FritzTestCase {

  func testSetWifi() {
    XCTAssertFalse(FritzVisionHairSegmentationModelFast.wifiRequiredForModelDownload)
    FritzVisionHairSegmentationModelFast.wifiRequiredForModelDownload = true
    XCTAssertTrue(FritzVisionHairSegmentationModelFast.wifiRequiredForModelDownload)
  }

  func testBlendImage() {
    let model = FritzVisionHairSegmentationModelFast()
    let image = TestImage.hair.fritzImage
    let result = try! model.predict(image)

    guard
      let mask = result.buildSingleClassMask(
        forClass: FritzVisionHairClass.hair,
        clippingScoresAbove: 1.0,
        zeroingScoresBelow: 0.0,
        resize: false,
        color: .blue
      )
    else {
      XCTFail()
      return
    }

    let blended = image.blend(
      withMask: mask,
      blendKernel: .softLight,
      resizeSamplingMethod: .lanczos,
      opacity: 0.3
    )
    XCTAssertNotNil(blended)

    let expectedEvents: [SessionEvent.EventType] = [
      .modelInstalled,
      .prediction,
    ]

    XCTAssertEqual(self.trackedEventTypes(), expectedEvents)
  }

  func testCenterCrop() {
    let model = FritzVisionHairSegmentationModelFast()
    let options = FritzVisionSegmentationModelOptions()
    options.imageCropAndScaleOption = .centerCrop
    let image = TestImage.hair.fritzImage
    let result = try! model.predict(image, options: options)

    guard
      let mask = result.buildSingleClassMask(
        forClass: FritzVisionHairClass.hair,
        clippingScoresAbove: 1.0,
        zeroingScoresBelow: 0.0,
        resize: false,
        color: .blue
      )
    else {
      XCTFail()
      return
    }

    XCTAssertEqual(
      image.size.height / image.size.width,
      mask.size.height / mask.size.width,
      accuracy: 0.01
    )

    guard
      let resizedMask = result.buildSingleClassMask(
        forClass: FritzVisionHairClass.hair,
        clippingScoresAbove: 1.0,
        zeroingScoresBelow: 0.0,
        resize: true,
        color: .blue
      )
    else {
      XCTFail()
      return
    }

    XCTAssertEqual(image.size, resizedMask.size)
    let blended = image.blend(
      withMask: mask,
      blendKernel: .softLight,
      opacity: 1.0
    )
    XCTAssertNotNil(blended)

    let expectedEvents: [SessionEvent.EventType] = [
      .modelInstalled,
      .prediction,
    ]

    XCTAssertEqual(self.trackedEventTypes(), expectedEvents)
  }
}
