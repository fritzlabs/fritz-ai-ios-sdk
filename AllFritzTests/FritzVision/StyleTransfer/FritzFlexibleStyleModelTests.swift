//
//  FritzFlexibleStyleModelTests.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 12/27/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzManagedModel
@testable import FritzVision

extension horses_on_seashore_512x512_a025_stable_flexible: SwiftIdentifiedModel {

  static let modelIdentifier = "flexible_horse"

  static let packagedModelVersion = 1

}

extension rigid_style_model: SwiftIdentifiedModel {

  static let modelIdentifier = "flexible_horse"

  static let packagedModelVersion = 1

}

class FritzVisionFlexibleStyleModelBaseTests: FritzTestCase {
  func testInvalidModelFails() {
    // This should *not* throw an error, so try! is okay
    try! FritzVisionStylePredictor.validateModel(
      model: try! horses_on_seashore_512x512_a025_stable_flexible(configuration: MLModelConfiguration()).model
    )

    do {
      try FritzVisionStylePredictor.validateModel(model: try! Digits(configuration: MLModelConfiguration()).model)
    } catch {
      return
    }
    XCTFail("Should throw error")
  }

  func testPredictCustomImage() {
    let testModel = FritzVisionStylePredictor(
      model: try! horses_on_seashore_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
    )

    let testPairs = [
      (FlexibleModelDimensions.lowResolution, FlexibleModelDimensions.lowResolution.size!),
      (FlexibleModelDimensions.mediumResolution, FlexibleModelDimensions.mediumResolution.size!),
      (FlexibleModelDimensions.highResolution, FlexibleModelDimensions.highResolution.size!),
      (FlexibleModelDimensions.original, CGSize(width: 300, height: 300)),
    ]

    for (dimensions, expected) in testPairs {
      let options = FritzVisionStyleModelOptions()
      options.flexibleModelDimensions = dimensions
      let image = TestImage.indoor.fritzImage

      let imageBuffer = try? testModel.predict(image, options: options)
      let width = CVPixelBufferGetWidth(imageBuffer!)
      let height = CVPixelBufferGetHeight(imageBuffer!)

      XCTAssertNotNil(imageBuffer)
      XCTAssertEqual(Int(expected.height), height)
      XCTAssertEqual(Int(expected.width), width)
    }
  }

  func testPredictWithResize() {
    let testModel = FritzVisionStylePredictor(
      model: try! horses_on_seashore_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
    )

    let image = TestImage.indoor.fritzImage
    let expectedWidth = Int(image.size.width)
    let expectedHeight = Int(image.size.height)

    let options = FritzVisionStyleModelOptions()
    options.resizeOutputToInputDimensions = true

    let imageBuffer = try? testModel.predict(image, options: options)
    let width = CVPixelBufferGetWidth(imageBuffer!)
    let height = CVPixelBufferGetHeight(imageBuffer!)

    XCTAssertNotNil(imageBuffer)
    XCTAssertEqual(expectedWidth, width)
    XCTAssertEqual(expectedHeight, height)
  }

  func testInvalidImageSize() {
    let testModel = FritzVisionStylePredictor(
      model: try! horses_on_seashore_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
    )

    let minDimensions = CGSize(width: 100, height: 100)
    let maxDimensions = CGSize(width: 1920, height: 1920)
    let error = FritzStyleModelSpecificationError.invalidImageSize(
      minDimensions: minDimensions,
      maxDimensions: maxDimensions
    )
    let testPairs = [
      (FlexibleModelDimensions(width: 99, height: 99), error),
      (FlexibleModelDimensions(width: 1921, height: 1921), error),
    ]

    for (dimensions, _) in testPairs {
      let exp = XCTestExpectation(description: "The model runs")
      let options = FritzVisionStyleModelOptions()
      options.flexibleModelDimensions = dimensions
      let image = TestImage.indoor.fritzImage
      testModel.predict(image, options: options) { (imageBuffer, error) in
        XCTAssertNil(imageBuffer)
        switch error! {
        case let FritzStyleModelSpecificationError.invalidImageSize(actualMin, actualMax):
          XCTAssertEqual(minDimensions, actualMin)
          XCTAssertEqual(maxDimensions, actualMax)
          exp.fulfill()
        default:
          break
        }
      }
      wait(for: exp)
    }
  }

  func testRigidModel() {
    let model = FritzVisionStylePredictor(model: try! rigid_style_model(configuration: MLModelConfiguration()))
    let image = TestImage.blonde.fritzImage
    var output: CVPixelBuffer = try! model.predict(image)
    var extent = CIImage(cvPixelBuffer: output).extent
    XCTAssertEqual(extent.size, CGSize(width: 480, height: 640))

    let options = FritzVisionStyleModelOptions()
    options.resizeOutputToInputDimensions = true
    output = try! model.predict(image, options: options)
    extent = CIImage(cvPixelBuffer: output).extent
    XCTAssertEqual(extent.size, image.size)
  }

  func testPredictFritzMLModel() {
    let config = FritzModelConfiguration(from: try! horses_on_seashore_512x512_a025_stable_flexible(configuration: MLModelConfiguration()))
    let fritzMLModel = FritzMLModel(
      model: try! horses_on_seashore_512x512_a025_stable_flexible(configuration: MLModelConfiguration()).model,
      activeModelConfig: config,
      sessionManager: sessionManager
    )

    let testModel = try! FritzVisionStylePredictor(model: fritzMLModel)
    let image = TestImage.indoor.fritzImage

    let imageBuffer = try? testModel.predict(image)
    XCTAssertNotNil(imageBuffer)

    let trackedRequests = trackedEventTypes(with: fritzMLModel.sessionManager)
    let expected: [SessionEvent.EventType] = [
      .modelInstalled,
      .prediction,
    ]

    XCTAssertEqual(expected, trackedRequests)
  }
}
