//
//  OperationRetrierTestCase.swift
//  FritzTests
//
//  Created by Andrew Barba on 11/7/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzCore
@testable import FritzManagedModel

class OperationRetrierTestCase: FritzTestCase {

  var successExp: XCTestExpectation?

  var failedExp: XCTestExpectation?

  var attemptedRetries: Int = 0

  var attemptRetries: Int = 0

  override func setUp() {
    super.setUp()
    successExp = nil
    failedExp = nil
    attemptedRetries = 0
    attemptRetries = 0
  }

  func testSuccessOneRetry() {
    successExp = XCTestExpectation(description: "retrier succeeded")
    attemptRetries = 1
    let retrier = createRetrier(maxRetries: 1)
    retrier.start()
    wait(for: successExp!)
    XCTAssertEqual(attemptedRetries, 1)
    XCTAssertEqual(retrier.attemptedRetries, 1)
  }

  func testSuccessTenRetries() {
    successExp = XCTestExpectation(description: "retrier succeeded")
    attemptRetries = 10
    let retrier = createRetrier(maxRetries: 10)
    retrier.start()
    wait(for: successExp!)
    XCTAssertEqual(attemptedRetries, 10)
    XCTAssertEqual(retrier.attemptedRetries, 10)
  }

  func testFailureOneRetry() {
    failedExp = XCTestExpectation(description: "retrier failed")
    attemptRetries = 2
    let retrier = createRetrier(maxRetries: 1)
    retrier.start()
    wait(for: failedExp!)
    XCTAssertEqual(attemptedRetries, 1)
    XCTAssertEqual(retrier.attemptedRetries, 1)
  }

  func testFailureTenRetries() {
    failedExp = XCTestExpectation(description: "retrier failed")
    attemptRetries = 11
    let retrier = createRetrier(maxRetries: 10)
    retrier.start()
    wait(for: failedExp!)
    XCTAssertEqual(attemptedRetries, 10)
    XCTAssertEqual(retrier.attemptedRetries, 10)
  }

  func testPauseRetry() {
    successExp = XCTestExpectation(description: "retrier succeeded")
    attemptRetries = 1
    let retrier = createRetrier(maxRetries: 1)
    retrier.start()
    XCTAssert(!retrier.isPaused)
    retrier.stop()
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { retrier.start() }
    XCTAssert(retrier.isPaused)
    wait(for: successExp!)
    XCTAssertEqual(attemptedRetries, 1)
    XCTAssertEqual(retrier.attemptedRetries, 1)
  }

  private func createRetrier(maxRetries: UInt) -> OperationRetrier {
    let handler = OperationRetryHandler(
      retryQueue: .main,
      retry: { completionHandler in
        self.attemptedRetries += 1
        let done = self.attemptedRetries == self.attemptRetries
        completionHandler(done ? .success : .error)
      },
      onSuccess: { self.successExp?.fulfill() },
      onFailure: { _ in self.failedExp?.fulfill() }
    )
    return OperationRetrier(handler: handler, maxRetries: maxRetries, exponentialMultiplier: 1)
  }
}
