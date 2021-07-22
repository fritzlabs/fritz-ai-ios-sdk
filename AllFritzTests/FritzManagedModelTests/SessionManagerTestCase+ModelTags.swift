//
//  SessionManager+ModelTags.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 1/21/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import XCTest

@testable import FritzCore
@testable import FritzManagedModel

class SessionManagerTagsTestCase: FritzTestCase {
  
  func testReadServerModel() throws {
    let exp = expectation(description: "Read models for tags")
    let expectedModelIDs = ["digits-2", "digits", "style-transfer-model"]

    // Note that in this test, the actual tags specified don't matter.  S3, where we're storing our test data
    // doesn't let you specify query parameters.
    sessionManager.readActiveModelsForTags(tags: ["premium", "holiday"]) {
      activeServerModels,
      error in
      guard let activeModels = activeServerModels else {
        exp.fulfill()
        return
      }
      // There is no backend and the models aren't local so there should be no way to get here
      XCTFail()
    }
    wait(for: exp)
  }
}
