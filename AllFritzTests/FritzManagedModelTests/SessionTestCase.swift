//
//  SessionTestCase.swift
//  FritzTests
//
//  Created by Andrew Barba on 11/7/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzCore
@testable import FritzManagedModel

class SessionTestCase: FritzTestCase {

  func testProvidedTokenAndEnvironment() {
    let apiKey = UUID().uuidString
    let session = Session(apiKey: apiKey)
    XCTAssertEqual(session.apiKey, apiKey)
    XCTAssertEqual(session.apiUrl, "http://localhost:port/sdk/v1")
    XCTAssertEqual(session.namespace, "Production")
  }

  func testProvidedToken() {
    let apiKey = UUID().uuidString
    let apiUrl = UUID().uuidString
    let namespace = UUID().uuidString
    let session = Session(apiKey: apiKey, apiUrl: apiUrl, namespace: namespace)
    XCTAssertEqual(session.apiKey, apiKey)
    XCTAssertEqual(session.apiUrl, apiUrl)
    XCTAssertEqual(session.namespace, namespace)
  }
}
