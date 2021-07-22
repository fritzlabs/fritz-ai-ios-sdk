//
//  FritzAPIKeyValidationTests.swfit.swift
//  AllFritzTests
//
//  Created by Eric Hsiao on 7/12/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import XCTest

@testable import FritzCore
@testable import FritzManagedModel

class FritzAPIKeyValidationTests: FritzTestCase {

  func testFatalError() {
    let json = """
      {
          "error": "authError",
          "message": "Invalid API Key",
          "is_fatal": true
      }
      """.data(using: .utf8)!

    do {
      let requestError = try JSONDecoder().decode(FritzRequestError.self, from: json)
      XCTAssertTrue(requestError.isFatal)
    } catch {
      XCTFail()
    }
  }

  func testNonFatalError() {
    let json = """
      {
          "error": "another Error",
          "message": "Do something",
      }
      """.data(using: .utf8)!

    do {
      let requestError = try JSONDecoder().decode(FritzRequestError.self, from: json)
      XCTAssertFalse(requestError.isFatal)
    } catch {
      XCTFail("Failed to decode json")
    }
  }
}
