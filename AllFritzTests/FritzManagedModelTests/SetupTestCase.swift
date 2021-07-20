//
//  SetupTestCase.swift
//  Fritz
//
//  Created by Andrew Barba on 11/7/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import FritzManagedModel
import XCTest

@testable import FritzCore

class SetupTestCase: FritzTestCase {

  func testUpdateIfNeeded() throws {
    let exp = XCTestExpectation(description: "update model if needed")
    Digits.updateIfNeeded { updated, error in
      XCTAssertFalse(updated)
      XCTAssertNotNil(error)
      exp.fulfill()
    }
    wait(for: exp)
  }
}
