//
//  FritzInflexibleStyleModelTests.swift
//  FritzInflexibleStyleModelTests
//
//  Created by Christopher Kelly on 8/6/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//
import XCTest

@testable import FritzManagedModel
@testable import FritzVision

extension starry_night_640x480_025: SwiftIdentifiedModel {

  static let modelIdentifier = "starrynight"

  static let packagedModelVersion = 1
}

class FritzInflexibleStyleModelTests: FritzTestCase {

  let starryNight = try! starry_night_640x480_025(configuration: MLModelConfiguration())

  func testInvalidModelFails() {

    // this should *not* throw an error, so try! is okay
    try! FritzVisionStylePredictor.validateModel(model: starryNight.model)

    do {
      try FritzVisionStylePredictor.validateModel(model: try! Digits(configuration: MLModelConfiguration()).model)
    } catch {
      return
    }
    XCTFail("Should throw error")
  }

  func testPredictCustomImage() {
    let testModel = FritzVisionStylePredictor(model: starryNight)

    let image = TestImage.indoor.fritzImage

    // Expected size is the size of the model output
    let expectedSize = CGSize(width: 480, height: 640)

    let imageBuffer = try? testModel.predict(image)
    let width = CVPixelBufferGetWidth(imageBuffer!)
    let height = CVPixelBufferGetHeight(imageBuffer!)

    XCTAssertNotNil(imageBuffer)
    XCTAssertEqual(Int(expectedSize.height), height)
    XCTAssertEqual(Int(expectedSize.width), width)
  }

  func testPredictWithResize() {
    let testModel = FritzVisionStylePredictor(model: starryNight)

    let image = TestImage.indoor.fritzImage
    let expectedWidth = Int(image.size.width)
    let expectedHeight = Int(image.size.height)

    // Resize the output to the input size
    let styleModelOptions = FritzVisionStyleModelOptions()
    styleModelOptions.resizeOutputToInputDimensions = true

    let imageBuffer = try? testModel.predict(image, options: styleModelOptions)
    let width = CVPixelBufferGetWidth(imageBuffer!)
    let height = CVPixelBufferGetHeight(imageBuffer!)

    XCTAssertNotNil(imageBuffer)
    XCTAssertEqual(expectedHeight, height)
    XCTAssertEqual(expectedWidth, width)
  }

  func testPredictFritzMLModel() {
    let config = FritzModelConfiguration(from: starryNight)
    let fritzMLModel = FritzMLModel(
      model: starryNight.model,
      activeModelConfig: config,
      sessionManager: starryNight.configuration.sessionManager
    )

    let testModel = try! FritzVisionStylePredictor(model: fritzMLModel)
    let image = TestImage.indoor.fritzImage

    let imageBuffer = try? testModel.predict(image)
    XCTAssertNotNil(imageBuffer)

    let trackedRequests = fritzMLModel.sessionManager.trackRequestQueue.items.map { $0.type }
    let expected: [SessionEvent.EventType] = [
      .modelInstalled,
      .prediction,
    ]
    XCTAssertEqual(expected, trackedRequests)

  }
  
  func testFetchModelsForTags() throws {
    let exp = XCTestExpectation(description: "Nothing happens")

    var sessionManager: SessionManager!
    FritzVisionStylePredictor.fetchStyleModelsForTags(
      tags: ["style-transfer", "painting"],
      wifiRequiredForModelDownload: true
    ) { styleModels, error in
      XCTAssertNotNil(error)
      guard let models = styleModels else {
        exp.fulfill()
        return
      }
      // No data should be pulled so we should never end up here
      XCTFail()
    }
  }

  func testFetchModelsForTagsWithBackend() throws {
    try XCTSkipIf(true, "Skip test with no backend")
    let exp = XCTestExpectation(description: "The model runs")

    var sessionManager: SessionManager!
    FritzVisionStylePredictor.fetchStyleModelsForTags(
      tags: ["style-transfer", "painting"],
      wifiRequiredForModelDownload: true
    ) { styleModels, error in
      XCTAssertNil(error)
      guard let models = styleModels else {
        XCTFail()
        return
      }
      XCTAssertEqual(1, models.count)
      let model = models[0]
      XCTAssertTrue(model.model.activeModelConfig.wifiRequiredForModelDownload)
      let image = TestImage.indoor.fritzImage
      sessionManager = model.model.sessionManager

      let imageBuffer = try? model.predict(image)
      XCTAssertNotNil(imageBuffer)
      exp.fulfill()
    }
    wait(for: exp)

    let trackedRequests = trackedEventTypes(with: sessionManager)
    let expected: [SessionEvent.EventType] = [
      .modelDownloadCompleted,
      .modelCompileCompleted,
      .modelInstalled,
      .prediction,
    ]
    XCTAssertEqual(expected, trackedRequests)

    // Check that overriding models properly sets wifi restrictions.
    let fetchExp = expectation(description: "Fetched Style Models")
    FritzVisionStylePredictor.fetchStyleModelsForTags(
      tags: ["style-transfer", "painting"],
      wifiRequiredForModelDownload: false
    ) { styleModels, error in

      guard let models = styleModels else {
        XCTFail()
        return
      }
      XCTAssertEqual(1, models.count)
      let model = models[0]
      XCTAssertFalse(model.model.activeModelConfig.wifiRequiredForModelDownload)
      fetchExp.fulfill()
    }
    wait(for: fetchExp)
  }
}
