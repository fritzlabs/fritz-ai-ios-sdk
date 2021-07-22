//
//  ManagedMLModelTestCase.swift
//  FritzTests
//
//  Created by Andrew Barba on 11/8/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzCore
@testable import FritzManagedModel

class FritzMLModelTestCase: FritzTestCase {

  func testModelSession() {
    let fritzModel = model.fritzModel()
    XCTAssertEqual(fritzModel.sessionManager.session, sessionManager.session)
  }

  func testWorkingPrediction() {
    let fritzModel = model.fritzModel()
    let input = try! MLDictionaryFeatureProvider(dictionary: ["input1": MLMultiArray(shape: [1, 28, 28], dataType: .double)])
    let _ = try! fritzModel.prediction(from: input)
    let trackedEvents = fritzModel.sessionManager.trackRequestQueue.items
    let expectedTrackedEvents: [SessionEvent.EventType] = [
      .modelInstalled,
      .prediction,
    ]
    XCTAssertEqual(trackedEvents.map { $0.type }, expectedTrackedEvents)
  }

  func testBadPrediction() {
    let fritzModel = model.fritzModel()
    do {
      let input = try! MLDictionaryFeatureProvider(dictionary: ["input1": MLMultiArray()])
      let _ = try fritzModel.prediction(from: input)
      XCTFail()
    } catch {
      XCTAssertEqual(fritzModel.sessionManager.trackRequestQueue.items.count, 2)
    }
  }

  func testBadPredictionWithOptions() {
    let fritzModel = model.fritzModel()

    do {
      let input = try! MLDictionaryFeatureProvider(dictionary: ["input1": MLMultiArray()])
      let _ = try fritzModel.prediction(from: input, options: MLPredictionOptions())
      XCTFail()
    } catch {
      let _ = fritzModel
      let expectedEvents: [SessionEvent.EventType] = [
        .modelInstalled,
        .prediction,
      ]
      XCTAssertEqual(sessionManager.trackRequestQueue.items.map { $0.type }, expectedEvents)
    }
  }

  func testModelUpdatedDifferentIdentifier() {
    let fritzModel = model.fritzModel()
    let exp = XCTestExpectation(description: "model updated")
    let info = LocalModelInfo(
      id: "bogus-identifier",
      version: fritzModel.version + 1,
      compiledModelURL: nil,
      isOTA: false
    )
    XCTAssertNotEqual(fritzModel.version, info.version)
    NotificationCenter.default.post(name: .modelUpdated, object: info)
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
      XCTAssertNotEqual(fritzModel.version, info.version)
      exp.fulfill()
    }
    wait(for: exp)
  }

}
