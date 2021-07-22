//
//  SessionManagerTestCase.swift
//  FritzTests
//
//  Created by Andrew Barba on 9/27/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzCore
@testable import FritzManagedModel

class SessionManagerTestCase: FritzTestCase {

  var notificationObserver: Any?

  override func setUp() {
    super.setUp()
    notificationObserver = nil
  }

  func testReadServerModelError() {
    let exp = XCTestExpectation(description: "read server model error")
    let description = FritzModelConfiguration(
      identifier: DigitsFake.modelIdentifier,
      version: DigitsFake.packagedModelVersion
    )
    sessionManager.readServerModel(description) { info, error in
      XCTAssertNotNil(error)
      XCTAssertNil(info)
      exp.fulfill()
    }
    wait(for: exp)
  }

  func testSessionSettings() {
    let settingsOff = SessionSettings(apiRequestsEnabled: false)
    SessionSettings.setSettings(settingsOff, for: sessionManager.session)

    let start = Date().timeIntervalSinceNow
    let exp = XCTestExpectation(description: "read server model error")
    sessionManager.readServerModel(FritzModelConfiguration(from: model)) { info, error in
      XCTAssertNotNil(error)
      XCTAssertNil(info)
      exp.fulfill()
    }
    wait(for: exp)
    let diff = Date().timeIntervalSinceNow - start

    // If api requests are disabled, this would essentially return on the same runloop
    XCTAssertLessThanOrEqual(diff, 0.0002)

    let settingsOn = SessionSettings(apiRequestsEnabled: true)
    SessionSettings.setSettings(settingsOn, for: sessionManager.session)
  }

  func testEventBlacklist() {
    let fritzModel = model.fritzModel()
    guard let input = try? MLDictionaryFeatureProvider(dictionary: ["input1": MLMultiArray(shape: [1, 28, 28], dataType: MLMultiArrayDataType.double)])
    else {
      fatalError("Unexpected runtime error. MLMultiArray")
    }

    // Test that blacklist filters out prediction event.
    let noPredictions = SessionSettings(eventBlacklist: ["prediction"])
    SessionSettings.setSettings(noPredictions, for: sessionManager.session)
    let _ = try! fritzModel.prediction(from: input)

    var expectedEvents: [SessionEvent.EventType] = [
      .modelInstalled,
    ]

    XCTAssertEqual(expectedEvents, sessionManager.trackRequestQueue.items.map { $0.type })

    // Test that prediction event successfully fires when no events blacklisted.
    let withPredictions = SessionSettings(eventBlacklist: [])
    SessionSettings.setSettings(withPredictions, for: sessionManager.session)
    let _ = try! fritzModel.prediction(from: input)
    expectedEvents.append(.prediction)
    XCTAssertEqual(sessionManager.trackRequestQueue.items.map { $0.type }, expectedEvents)
  }

}
