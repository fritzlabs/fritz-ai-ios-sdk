//
//  SessionSettingsTestCase.swift
//  FritzTests
//
//  Created by Andrew Barba on 2/7/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzCore
@testable import FritzManagedModel

class SessionSettingsTestCase: FritzTestCase {

  func testRandomSampling0Percent() {
    let settings = SessionSettings(
      apiRequestsEnabled: true,
      settingsRefreshInterval: 60,
      modelInputOutputSamplingRatio: 0
    )
    let samples = (0..<1000).map { _ in settings.shouldSampleInputOutput() }.filter { $0 }
    XCTAssertEqual(samples.count, 0)
  }

  func testRandomSampling10Percent() {
    let settings = SessionSettings(
      apiRequestsEnabled: true,
      settingsRefreshInterval: 60,
      modelInputOutputSamplingRatio: 0.10
    )
    let samples = (0..<1000).map { _ in settings.shouldSampleInputOutput() }.filter { $0 }
    XCTAssertGreaterThanOrEqual(samples.count, 50)
    XCTAssertLessThanOrEqual(samples.count, 150)
  }

  func testRandomSampling50Percent() {
    let settings = SessionSettings(
      apiRequestsEnabled: true,
      settingsRefreshInterval: 60,
      modelInputOutputSamplingRatio: 0.50
    )
    let samples = (0..<1000).map { _ in settings.shouldSampleInputOutput() }.filter { $0 }
    XCTAssertGreaterThanOrEqual(samples.count, 450)
    XCTAssertLessThanOrEqual(samples.count, 550)
  }

  func testRandomSampling90Percent() {
    let settings = SessionSettings(
      apiRequestsEnabled: true,
      settingsRefreshInterval: 60,
      modelInputOutputSamplingRatio: 0.90
    )
    let samples = (0..<1000).map { _ in settings.shouldSampleInputOutput() }.filter { $0 }
    XCTAssertGreaterThanOrEqual(samples.count, 850)
    XCTAssertLessThanOrEqual(samples.count, 950)
  }

  func testRandomSampling100Percent() {
    let settings = SessionSettings(
      apiRequestsEnabled: true,
      settingsRefreshInterval: 60,
      modelInputOutputSamplingRatio: 1.00
    )
    let samples = (0..<1000).map { _ in settings.shouldSampleInputOutput() }.filter { $0 }
    XCTAssertEqual(samples.count, 1000)
  }
}
