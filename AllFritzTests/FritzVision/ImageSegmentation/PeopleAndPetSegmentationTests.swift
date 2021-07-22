//
//  PeopleAndPetSegmentationTests.swift
//  AllFritzTests
//
//  Created by Eric Hsiao on 4/8/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import FritzVision
import XCTest

@testable import FritzVision
@testable import FritzVisionPeopleAndPetSegmentationModelAccurate

class FritzVisionPeopleAndPetSegmentationMediumModelTests: FritzTestCase {

  func testSetWifi() {
    XCTAssertFalse(FritzVisionPeopleAndPetSegmentationModelAccurate.wifiRequiredForModelDownload)
    FritzVisionPeopleAndPetSegmentationModelAccurate.wifiRequiredForModelDownload = true
    XCTAssertTrue(FritzVisionPeopleAndPetSegmentationModelAccurate.wifiRequiredForModelDownload)
  }

  func testPredictionReportsToAPIAndIsReasonable() {
    let model = FritzVisionPeopleAndPetSegmentationModelAccurate()
    let image = TestImage.person.fritzImage

    let result = try! model.predict(image)

    let classes = result.getArrayOfMostLikelyClasses()
    let total = Float(classes.reduce(0, { $0 + $1 }))

    XCTAssertEqual(total, 226_000, accuracy: 1000)

    let expectedEvents: [SessionEvent.EventType] = [
      .modelInstalled,
      .prediction,
    ]
    XCTAssertEqual(self.trackedEventTypes(), expectedEvents)
  }
}
