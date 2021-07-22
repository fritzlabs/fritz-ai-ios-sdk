//
//  FritzMockedRequestTestCase.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 11/14/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import Hippolyte
@testable import FritzManagedModel
@testable import FritzCore

class FritzMockedRequestTestCase: FritzTestCase {
  
  let requestStubs = RequestStub()

  var stubbedSessionSettings: SessionSettings { SessionSettings() }

  override func setUp() {
    let stubs = [
      requestStubs.sessionSettings(stubbedSessionSettings),
      requestStubs.activeModel(Digits.self)
    ]
    for stub in stubs {
      Hippolyte.shared.add(stubbedRequest: stub)
    }
    Hippolyte.shared.start()
    super.setUp()
  }
  
  override func tearDown() {
    Hippolyte.shared.stop()
    super.tearDown()
  }

  func updateSessionSettings(_ settings: SessionSettings) {
    let stub = requestStubs.sessionSettings(settings)
    Hippolyte.shared.add(stubbedRequest: stub)
    FritzCore.configuration.sessionManager.loadSessionSettings()
  }
}

