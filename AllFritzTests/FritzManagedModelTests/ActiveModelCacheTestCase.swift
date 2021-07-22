//
//  ActiveModelCacheTestCase.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 1/22/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import XCTest

@testable import FritzManagedModel

class FritzActiveModelCacheTestsCase: FritzTestCase {

  func testSavesCacheOnUpdate() {
    let savedActiveVersion = ActiveServerModel(
      id: "testId",
      version: 1,
      src: nil,
      tags: ["tag1"],
      metadata: nil
    )

    ServerModelCache.shared.update([savedActiveVersion])

    let cacheLoadedFromDisk = SessionManager.localModelManager.loadAllModels()
    XCTAssertEqual(cacheLoadedFromDisk!.models, [savedActiveVersion])
  }

  func testProperUpdating() {
    let savedActiveVersion = ActiveServerModel(
      id: "testId",
      version: 1,
      src: nil,
      tags: ["tag1"],
      metadata: nil
    )
    ServerModelCache.shared.update([savedActiveVersion])
    XCTAssertEqual(ServerModelCache.shared.models, [savedActiveVersion])

    let newActiveVersion = ActiveServerModel(
      id: "testId",
      version: 2,
      src: nil,
      tags: ["tag1"],
      metadata: nil
    )
    ServerModelCache.shared.update([newActiveVersion])
    XCTAssertEqual(ServerModelCache.shared.models, [newActiveVersion])

    let cacheLoadedFromDisk = SessionManager.localModelManager.loadAllModels()
    XCTAssertEqual(cacheLoadedFromDisk!.models, [newActiveVersion])
  }
}
