//
//  BatchedRequestQueueTestCase.swift
//  FritzTests
//
//  Created by Andrew Barba on 11/7/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzCore
@testable import FritzManagedModel

class BatchedRequestQueueTestCase: FritzTestCase {

  private var successResponse: Response {
    return .success(data: Data())
  }

  private var timeoutResponse: Response {
    let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
    return .error(error: error, response: nil, data: nil)
  }

  func testSingleFlush() {
    let exp = XCTestExpectation(description: "flush 1 item")
    let session = sessionManager.session
    let sessionSettings = SessionSettings(trackRequestBatchSize: 1, batchFlushInterval: 60)
    SessionSettings.setSettings(sessionSettings, for: session)
    let queue = BatchedRequestQueue<Int>(
      session: session,
      flushQueue: .main,
      exponentialMultiplier: 10
    )
    queue.onFlush = { items, cb in
      XCTAssertEqual(items.count, 1)
      XCTAssertEqual(items[0], 99)
      cb(self.successResponse)
      XCTAssertEqual(queue.items.count, 0)
      exp.fulfill()
    }
    queue.add(99)
    wait(for: exp)
  }

  func testTimerFlush() {
    let exp = XCTestExpectation(description: "flush 1 item")
    let session = sessionManager.session
    let sessionSettings = SessionSettings(trackRequestBatchSize: 1, batchFlushInterval: 60)
    SessionSettings.setSettings(sessionSettings, for: session)
    let queue = BatchedRequestQueue<Int>(
      session: session,
      flushQueue: .main,
      exponentialMultiplier: 10
    )
    queue.onFlush = { items, cb in
      XCTAssertEqual(items.count, 1)
      XCTAssertEqual(items[0], 99)
      cb(self.successResponse)
      XCTAssertEqual(queue.items.count, 0)
      exp.fulfill()
    }
    queue.add(99)
    wait(for: exp)
  }

  func testForceFlush() {
    let exp = XCTestExpectation(description: "flush 1 item")
    let session = sessionManager.session
    let sessionSettings = SessionSettings(trackRequestBatchSize: 10, batchFlushInterval: 60)
    SessionSettings.setSettings(sessionSettings, for: session)
    let queue = BatchedRequestQueue<Int>(
      session: session,
      flushQueue: .main,
      exponentialMultiplier: 10
    )
    queue.onFlush = { items, cb in
      XCTAssertEqual(items.count, 1)
      XCTAssertEqual(items[0], 99)
      cb(self.successResponse)
      XCTAssertEqual(queue.items.count, 0)
      exp.fulfill()
    }
    queue.add(99)
    queue.flush(force: true)
    wait(for: exp)
  }

  func testDoubleFlush() {
    let exp = XCTestExpectation(description: "flush 1 item")
    let session = sessionManager.session
    let sessionSettings = SessionSettings(trackRequestBatchSize: 2, batchFlushInterval: 60)
    SessionSettings.setSettings(sessionSettings, for: session)
    let queue = BatchedRequestQueue<Int>(
      session: session,
      flushQueue: .main,
      exponentialMultiplier: 10
    )
    queue.onFlush = { items, cb in
      XCTAssertEqual(items.count, 2)
      XCTAssertEqual(items[0], 99)
      XCTAssertEqual(items[1], 98)
      cb(self.successResponse)
      XCTAssertEqual(queue.items.count, 0)
      exp.fulfill()
    }
    queue.add(99)
    queue.add(98)
    wait(for: exp)
  }

  func testTimeout() {
    let exp = XCTestExpectation(description: "flush 1 item")
    let session = sessionManager.session
    let sessionSettings = SessionSettings(trackRequestBatchSize: 1, batchFlushInterval: 60)
    SessionSettings.setSettings(sessionSettings, for: session)
    let queue = BatchedRequestQueue<Int>(
      session: session,
      flushQueue: .main,
      exponentialMultiplier: 10
    )
    var flushFailures: Int = 0
    var healthcheckFailures: Int = 0
    queue.onFlush = { items, cb in
      if flushFailures < 2 {
        flushFailures += 1
        cb(self.timeoutResponse)
        return
      }
      XCTAssertEqual(flushFailures, 2)
      XCTAssertEqual(items.count, 1)
      XCTAssertEqual(items[0], 99)
      cb(self.successResponse)
      XCTAssertEqual(queue.items.count, 0)
      exp.fulfill()
    }
    queue.apiHealthcheck = { cb in
      if healthcheckFailures < 3 {
        healthcheckFailures += 1
        cb(false)
      } else {
        XCTAssertEqual(healthcheckFailures, 3)
        healthcheckFailures = 0
        cb(true)
      }
    }
    queue.add(99)
    wait(for: exp)
  }

  func testMaxHealthcheckRetries() {
    let exp = XCTestExpectation(description: "flush 1 item")
    let session = sessionManager.session
    let sessionSettings = SessionSettings(trackRequestBatchSize: 1, batchFlushInterval: 60)
    SessionSettings.setSettings(sessionSettings, for: session)
    let queue = BatchedRequestQueue<Int>(
      session: session,
      flushQueue: .main,
      maxRetries: 2,
      exponentialMultiplier: 10
    )
    var flushFailures: Int = 0
    var healthcheckFailures: Int = 0
    queue.onFlush = { items, cb in
      if flushFailures < 2 {
        flushFailures += 1
        cb(self.timeoutResponse)
        return
      }
      XCTAssertEqual(flushFailures, 2)
      XCTAssertEqual(items.count, 1)
      XCTAssertEqual(items[0], 99)
      cb(self.successResponse)
      XCTAssertEqual(queue.items.count, 0)
      exp.fulfill()
    }
    queue.apiHealthcheck = { cb in
      if healthcheckFailures < 4 {
        healthcheckFailures += 1
        cb(false)
      } else {
        XCTAssertEqual(healthcheckFailures, 4)
        healthcheckFailures = 0
        cb(true)
      }
    }
    queue.add(99)
    wait(for: exp)
  }
}
