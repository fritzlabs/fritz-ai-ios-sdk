//
//  SessionIdentifierTestCase.swift
//  FritzTests
//
//  Created by Andrew Barba on 11/8/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzCore
@testable import FritzManagedModel

class SessionIdentfifierTestCase: FritzTestCase {

  override func setUp() {
    super.setUp()
    FritzCore.clearSessionIdentifier()
  }

  func testSessionIdentifier() {
    let identifier1 = FritzCore.sessionIdentifier
    let identifier2 = FritzCore.resetSessionIdentifierIfNeeded()
    let identifier3 = FritzCore.sessionIdentifier
    XCTAssertEqual(identifier1, identifier2)
    XCTAssertEqual(identifier1, identifier3)
  }

  func testSessionIdentifierReset() {
    let identifier1 = FritzCore.sessionIdentifier
    FritzCore.clearSessionIdentifier()
    let identifier2 = FritzCore.sessionIdentifier
    let identifier3 = FritzCore.sessionIdentifier
    XCTAssertNotEqual(identifier1, identifier2)
    XCTAssertEqual(identifier2, identifier3)
  }

  func testSessionIdentifierExpired() {
    let identifier1 = FritzCore.sessionIdentifier
    FritzCore.storedSessionIdentifierDate
      = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - (5 * 60) - 1)
    XCTAssert(!FritzCore.isSessionIdentifierValid)
    let identifier2 = FritzCore.resetSessionIdentifierIfNeeded()
    let identifier3 = FritzCore.sessionIdentifier
    XCTAssertNotEqual(identifier1, identifier2)
    XCTAssertEqual(identifier2, identifier3)
  }

  func testSessionIdentifierNotExpired() {
    let identifier1 = FritzCore.sessionIdentifier
    FritzCore.storedSessionIdentifierDate
      = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - (5 * 60) + 1)
    XCTAssert(FritzCore.isSessionIdentifierValid)
    let identifier2 = FritzCore.resetSessionIdentifierIfNeeded()
    let identifier3 = FritzCore.sessionIdentifier
    XCTAssertEqual(identifier1, identifier2)
    XCTAssertEqual(identifier2, identifier3)
  }
}
