//
//  Fritz_SDKTests.swift
//  FritzTests
//
//  Created by Andrew Barba on 8/9/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import XCTest
import Hippolyte
@testable import FritzCore
@testable import FritzManagedModel


class FritzTestCase: XCTestCase {

  static var testSession: Session {
    Session(
      apiKey: "fritz-test-app-token",
      apiUrl: "http://localhost:port",
      namespace: "Test"
    )
  }

  lazy var model = try! Digits(configuration: MLModelConfiguration())

  let testAssets = TestAssets()

  lazy var modelVersion2 = DigitsDifferentVersion()

  lazy var modelVersion3 = DigitsPinnedVersion()

  lazy var sessionManager = Digits.resolvedConfiguration.sessionManager

  /// Local model manager
  lazy var localModelManager: LocalModelManager = {
    let fileManager = FileManager.default
    let documentsDirectory = try! fileManager.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: false
    )
    let fritzDirectory = documentsDirectory.appendingPathComponent(
      "Fritz/Models",
      isDirectory: true
    )
    return LocalModelManager(fileManager: fileManager, rootURL: fritzDirectory)
  }()

  // TODO: Switch this out to test against staging
  let productionSession = Session(
    apiKey: "f9a134a9cf614834bc72f5def48ce3bd"
  )

  /// Run before the first test
  override class func setUp() {
    super.setUp()
    let config = Configuration(
      session: Self.testSession
    )
    FritzCore.configure(with: config)
  }

  /// Run before every test method
  override func setUp() {
    XCTAssertTrue(FritzCore.isConfigured())
    let domain = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: domain)
    UserDefaults.standard.synchronize()
    super.setUp()
  }

  /// Run after every test method
  override func tearDown() {
    super.tearDown()

    // Clear any pending requests
    sessionManager.trackRequestQueue.clear()
    try? ServerModelCache.clear()
    // Reset session settings to defaults
    let sessionSettings = SessionSettings()
    SessionSettings.setSettings(sessionSettings, for: sessionManager.session)
    try? FileManager.default.removeItem(at: SessionManager.localModelManager.rootURL)
  }

  func trackedEventTypes(with sessionManager: SessionManager? = nil) -> [SessionEvent.EventType] {
    let sessionManager = sessionManager ?? FritzCore.configuration.sessionManager
    return sessionManager.trackRequestQueue.items.map { $0.type }
  }

  func wait(for expectation: XCTestExpectation, timeout: TimeInterval = 30) {
    wait(for: [expectation], timeout: timeout)
  }

  func wait(forAll expectations: [XCTestExpectation], timeout: TimeInterval = 30) {
    wait(for: expectations, timeout: timeout)
  }
}
