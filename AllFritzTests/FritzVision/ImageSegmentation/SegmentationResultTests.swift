//
//  SegmentationResultTests.swift
//  AllFritzTests
//
//  Created by Eric Hsiao on 7/23/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import FritzVision
import XCTest

@testable import FritzVisionPeopleSegmentationModelFast

class SegmentationResultTests: FritzTestCase {

  func testMasking() {
    let model = FritzVisionPeopleSegmentationModelAccurate()
    let image = TestImage.tennis.fritzImage


    let result = try! model.predict(image)

    let maskedImage = result.buildSingleClassMask(
      forClass: FritzVisionPeopleClass.person,
      clippingScoresAbove: 0.5,
      zeroingScoresBelow: 0.5,
      resize: true,
      color: .blue
    )!

    let clippedMaskImage = image.masked(with: maskedImage)
    XCTAssertNotNil(clippedMaskImage)

    let expectedEvents: [SessionEvent.EventType] = [
      .modelInstalled,
      .prediction,
    ]

    XCTAssertEqual(self.trackedEventTypes(), expectedEvents)
  }
}
