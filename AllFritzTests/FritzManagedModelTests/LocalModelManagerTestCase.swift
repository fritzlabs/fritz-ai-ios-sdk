//
//  LocalModelManagerTestCase.swift
//  FritzTests
//
//  Created by Andrew Barba on 11/7/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzCore
@testable import FritzManagedModel

class LocalModelManagerTestCase: FritzTestCase {

  func testCurrentInfoWithBundledModel() {
    let modelConfig = FritzModelConfiguration(from: model)
    let info = localModelManager.getOrCreateLocalInfo(modelConfig)
    let expectedInfo = LocalModelInfo(
      id: model.identifier,
      version: model.packagedModelVersion,
      compiledModelURL: nil,
      isOTA: false
    )
    XCTAssertEqual(info, expectedInfo)
  }
}
