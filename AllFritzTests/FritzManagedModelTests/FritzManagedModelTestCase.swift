import Foundation
//
//  FritzManagedModel.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 1/18/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//
import XCTest

@testable import FritzManagedModel

class FritzManagedModelInitializationTestCase: FritzTestCase {

  func testInitWithIdentifiedModel() {
    let managedModel = FritzManagedModel(identifiedModel: model)
    XCTAssertEqual(model.identifier, managedModel.id)
    XCTAssertEqual(model.packagedModelVersion, managedModel.version)
  }

  func testInitWithActiveModelVersion() {
    let newerModelConfig = FritzModelConfiguration(identifier: model.identifier, version: 10)
    try! SessionManager.localModelManager.persistActive(newerModelConfig)
    var managedModel = FritzManagedModel(identifiedModel: model)
    XCTAssertEqual(managedModel.version, 10)
    managedModel
      = FritzManagedModel(
        modelConfig: FritzModelConfiguration(identifier: model.identifier, version: 7),
        sessionManager: model.configuration.sessionManager
      )
    XCTAssertEqual(managedModel.version, 10)
  }

  func testInitWithPinnedModelVersion() {
    let modelConfig = FritzModelConfiguration(
      identifier: model.identifier,
      version: 10,
      pinnedVersion: 7
    )

    let managedModel = FritzManagedModel(modelConfig: modelConfig)
    managedModel.isNewerModelAvailable { (a, b) in
    }

    let active = managedModel.activeModelConfig
    XCTAssertEqual(active.version, 10)
    XCTAssertEqual(active.pinnedVersion, 7)
  }

  func testInitPinnedWithExistingNonPinnedModelVersion() {
    var modelConfig = FritzModelConfiguration(identifier: model.identifier, version: 10)
    try! localModelManager.persistActive(modelConfig)
    modelConfig
      = FritzModelConfiguration(identifier: model.identifier, version: 10, pinnedVersion: 17)
    let managedModel = FritzManagedModel(modelConfig: modelConfig)
    managedModel.isNewerModelAvailable { (a, b) in
    }

    let active = managedModel.activeModelConfig
    XCTAssertEqual(active.version, 10)
    XCTAssertEqual(active.pinnedVersion, 17)
  }

  func testInitNonPinnedWithExistingPinnedModelVersion() {
    var modelConfig = FritzModelConfiguration(
      identifier: model.identifier,
      version: 10,
      pinnedVersion: 21
    )
    try! localModelManager.persistActive(modelConfig)
    modelConfig = FritzModelConfiguration(identifier: model.identifier, version: 10)
    let managedModel = FritzManagedModel(modelConfig: modelConfig)
    managedModel.isNewerModelAvailable { (a, b) in
    }

    let active = managedModel.activeModelConfig
    XCTAssertEqual(active.version, 10)
    XCTAssertEqual(active.pinnedVersion, nil)
  }

  func testInitPinnedWithNewPinnedModelVersion() {
    var modelConfig = FritzModelConfiguration(
      identifier: model.identifier,
      version: 10,
      pinnedVersion: 21
    )
    try! localModelManager.persistActive(modelConfig)
    modelConfig
      = FritzModelConfiguration(identifier: model.identifier, version: 10, pinnedVersion: 15)
    let managedModel = FritzManagedModel(modelConfig: modelConfig)
    managedModel.isNewerModelAvailable { (a, b) in
    }

    let active = managedModel.activeModelConfig
    XCTAssertEqual(active.version, 10)
    XCTAssertEqual(active.pinnedVersion, 15)
  }

  func testInitWithPinnedIdentifiedModel() {
    let managedModel = FritzManagedModel(identifiedModel: modelVersion3)
    managedModel.isNewerModelAvailable { (a, b) in
    }

    let active = managedModel.activeModelConfig
    XCTAssertEqual(active.version, 2)
    XCTAssertEqual(active.pinnedVersion, 3)
  }

  func testInitWithPinnedIdentifiedModelType() {
    let managedModel = FritzManagedModel(identifiedModelType: type(of: modelVersion3))
    managedModel.isNewerModelAvailable { (a, b) in
    }

    let active = managedModel.activeModelConfig
    XCTAssertEqual(active.version, 2)
    XCTAssertEqual(active.pinnedVersion, 3)
  }

  func testInitPinnedIdentifiedWithNonPinnedIdentified() {
    var managedModel = FritzManagedModel(identifiedModel: modelVersion3)
    managedModel.isNewerModelAvailable { (a, b) in
    }

    XCTAssertEqual(managedModel.activeModelConfig.pinnedVersion, 3)
    managedModel = FritzManagedModel(identifiedModel: modelVersion2)
    XCTAssertEqual(managedModel.activeModelConfig.pinnedVersion, nil)
  }

  func testInitNonPinnedIdentifiedWithPinnedIdentified() {
    var managedModel = FritzManagedModel(identifiedModel: modelVersion2)
    managedModel.isNewerModelAvailable { (a, b) in
    }

    XCTAssertEqual(managedModel.activeModelConfig.pinnedVersion, nil)
    managedModel = FritzManagedModel(identifiedModel: modelVersion3)
    XCTAssertEqual(managedModel.activeModelConfig.pinnedVersion, 3)
  }
}

class FritzManagedModelLoadModelTestCase: FritzTestCase {

  func testLoadIdentifiedModel() {
    let managedModel = FritzManagedModel(identifiedModel: model)
    let fritzModel = managedModel.loadModel(identifiedModel: model)
    XCTAssertEqual(fritzModel.model, model.model)
  }

  func testWhenCompiledModelFailsToLoadItDoesntCrash() {
    // persisting invalid configs.
    let activeServerModel = ActiveServerModel(
      id: Digits.modelIdentifier,
      version: 2,
      src: URL(fileURLWithPath: "srcPath"),
      tags: nil,
      metadata: nil
    )
    let activeModelConfig = FritzModelConfiguration(
      from: activeServerModel,
      modelConfig: FritzModelConfiguration(from: model)
    )
    let infoWithBadModel = LocalModelInfo(
      id: Digits.modelIdentifier,
      version: 2,
      compiledModelURL: URL(fileURLWithPath: "fakePath"),
      isOTA: true
    )
    try! localModelManager.persistLocalModelInfo(infoWithBadModel)
    try! localModelManager.persistActive(activeModelConfig)

    let managedModel = FritzManagedModel(identifiedModel: model)
    let fritzModel = managedModel.loadModel(identifiedModel: try! Digits(configuration: MLModelConfiguration()))

    XCTAssertEqual(1, fritzModel.version)

    let missingLocalModel = localModelManager.loadLocalModelInfo(activeModelConfig)
    XCTAssertNil(missingLocalModel)

    let expectedActiveModelConfig = FritzModelConfiguration(
      identifier: Digits.modelIdentifier,
      version: 1
    )
    XCTAssertEqual(managedModel.activeModelConfig, expectedActiveModelConfig)
  }
}

extension DigitsDownload: SwiftIdentifiedModel {
  static let modelIdentifier = "digits"

  static let packagedModelVersion = 1
}

class DownloadModelFromSwiftIdentifiedModelTestCase: FritzTestCase {

  func testInitializeModelFromBaseIdentifiedModel() {
    let managedModel = FritzManagedModel(identifiedModelType: Digits.self)
    let model = managedModel.loadModel()
    XCTAssertNotNil(model)
  }
}
