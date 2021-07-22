//
//  FritzModelConfigurationTestCAse.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 1/25/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import XCTest

@testable import FritzCore
@testable import FritzManagedModel

class FritzModelConfigurationTestCase: FritzTestCase {

  // Note, these should be more generalized. If this tests grow, spend some time to make these builders better.
  func buildTagsResponseData() -> Data {
    let responseData: RequestOptions = [
      "id": "test_uid",
      "version": 1,
      "src": "https://testorsomething",
      "tags": ["tag1", "tag2"],
    ]
    return try! JSONSerialization.data(withJSONObject: responseData, options: [])
  }

  func buildMetadataResponseData() -> Data {
    let responseData: RequestOptions = [
      "id": "test_uid",
      "version": 1,
      "src": "https://testorsomething",
      "tags": ["tag1", "tag2"],
      "metadata": ["Hey I'm some model": "metadata"],
    ]
    return try! JSONSerialization.data(withJSONObject: responseData, options: [])
  }

  func testTagsGetLoadedAndPersisted() {
    let data = buildTagsResponseData()
    let info = try! JSONDecoder().decode(ActiveServerModel.self, from: data)
    let expectedActiveServerModel = ActiveServerModel(
      id: "test_uid",
      version: 1,
      src: URL(string: "https://testorsomething"),
      tags: ["tag1", "tag2"],
      metadata: nil
    )
    XCTAssertEqual(info, expectedActiveServerModel)
    let modelConfig = FritzModelConfiguration(
      from: info,
      modelConfig: FritzModelConfiguration(identifier: "test_uid", version: 1)
    )
    try! localModelManager.persistActive(modelConfig)
    let loadedModelConfig = localModelManager.loadActiveModelInfo(modelConfig)!
    XCTAssertEqual(modelConfig, loadedModelConfig)
  }

  func testMetadataLoadedAndPersisted() {
    let data = buildMetadataResponseData()
    let info = try! JSONDecoder().decode(ActiveServerModel.self, from: data)
    let expectedActiveServerModel = ActiveServerModel(
      id: "test_uid",
      version: 1,
      src: URL(string: "https://testorsomething"),
      tags: ["tag1", "tag2"],
      metadata: ["Hey I'm some model": "metadata"]
    )
    XCTAssertEqual(info, expectedActiveServerModel)
    let modelConfig = FritzModelConfiguration(
      from: info,
      modelConfig: FritzModelConfiguration(identifier: "test_uid", version: 1)
    )
    try! localModelManager.persistActive(modelConfig)
    let loadedModelConfig = localModelManager.loadActiveModelInfo(modelConfig)!
    XCTAssertEqual(modelConfig, loadedModelConfig)
    XCTAssertEqual("metadata", loadedModelConfig.metadata!["Hey I'm some model"])
    XCTAssertEqual(nil, loadedModelConfig.metadata!["Not a key"])
  }

  func testLoadingWithMoreValues() {
    let responseData: RequestOptions = [
      "id": "test_uid",
      "version": 1,
      "src": "https://testorsomething",
      "tags": ["tag1", "tag2"],
      "metadata": ["Hey I'm some model": "metadata"],
      "random_field": "hey i'm not suposed to be here",
    ]
    let data = try! JSONSerialization.data(withJSONObject: responseData, options: [])
    let info = try! JSONDecoder().decode(ActiveServerModel.self, from: data)
    let expectedActiveServerModel = ActiveServerModel(
      id: "test_uid",
      version: 1,
      src: URL(string: "https://testorsomething"),
      tags: ["tag1", "tag2"],
      metadata: ["Hey I'm some model": "metadata"]
    )
    XCTAssertEqual(info, expectedActiveServerModel)

  }
}
