//
//  ErrorsTestCase.swift
//  FritzTests
//
//  Created by Andrew Barba on 11/8/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzCore
@testable import FritzManagedModel

class ErrorsTestCase: FritzTestCase {

  func testErrorPost() {
    let exp = XCTestExpectation(description: "error posted")
    let observer = NotificationCenter.default.addObserver(
      forName: .fritzError,
      object: nil,
      queue: nil
    ) { notification in
      let error = notification.object as! FritzError
      XCTAssertEqual(error.domain, "Fritz-\(self.model.configuration.session.apiKey)")
      XCTAssertEqual(error.code, ErrorCode.modelCompilation.rawValue)
      exp.fulfill()
    }
    FritzError.post(
      session: model.configuration.session,
      modelIdentifier: model.identifier,
      code: .modelCompilation,
      error: NSError()
    )
    wait(for: exp)
    NotificationCenter.default.removeObserver(observer)

  }
}
