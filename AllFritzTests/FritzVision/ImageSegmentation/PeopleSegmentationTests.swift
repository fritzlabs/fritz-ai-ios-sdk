//
//  FritzVisionPeopleSegmentationModelFastTests.swift
//  FritzVisionPeopleSegmentationModelFastTests
//
//  Created by Christopher Kelly on 9/24/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import FritzVision
import XCTest

@testable import FritzVision
@testable import FritzVisionPeopleSegmentationModelAccurate
@testable import FritzVisionPeopleSegmentationModelFast

class FritzVisionPeopleSegmentationModelFastTests: FritzTestCase {

  func testSetWifi() {
    XCTAssertFalse(FritzVisionPeopleSegmentationModelFast.wifiRequiredForModelDownload)
    FritzVisionPeopleSegmentationModelFast.wifiRequiredForModelDownload = true
    XCTAssertTrue(FritzVisionPeopleSegmentationModelFast.wifiRequiredForModelDownload)
  }

  func testReportsToAPI() {
    let model = FritzVisionPeopleSegmentationModelFast()
    let image = TestImage.indoor.fritzImage

    model.predict(image) { result, error in
      if let _ = error {
        XCTFail("Error in fritz vision predict")
      }
    }
    let expectedEvents: [SessionEvent.EventType] = [
      .modelInstalled,
      .prediction,
    ]
    XCTAssertEqual(self.trackedEventTypes(), expectedEvents)
  }
}

class FritzVisionPeopleSegmentationModelAccurateTests: FritzTestCase {

  func testSetWifi() {
    XCTAssertFalse(FritzVisionPeopleSegmentationModelAccurate.wifiRequiredForModelDownload)
    FritzVisionPeopleSegmentationModelAccurate.wifiRequiredForModelDownload = true
    XCTAssertTrue(FritzVisionPeopleSegmentationModelAccurate.wifiRequiredForModelDownload)
  }

  func testReportsToAPI() {
    let model = FritzVisionPeopleSegmentationModelAccurate()
    let image = TestImage.indoor.fritzImage

    model.predict(image) { result, error in
      if let _ = error {
        XCTFail("Error in fritz vision predict")
      }
    }
    let expectedEvents: [SessionEvent.EventType] = [
      .modelInstalled,
      .prediction,
    ]
    XCTAssertEqual(self.trackedEventTypes(), expectedEvents)
  }
}
