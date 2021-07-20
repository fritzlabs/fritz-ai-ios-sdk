//
//  FritzVisionStyleTests.swift
//  FritzVisionStyleTests
//
//  Created by Christopher Kelly on 8/6/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzVision
@testable import FritzVisionStyleModelPaintings

class FritzVisionStyleTests: FritzTestCase {
  lazy var allModels: [FritzVisionStylePredictor] = {
    return PaintingStyleModel.Style.allCases.map { $0.build() }
  }()

  func testLoadingModels() {
    let exp = XCTestExpectation(description: "The model runs")
    XCTAssertEqual(9, allModels.count)
    let testModel = allModels[0]
    let image = TestImage.indoor.fritzImage
    testModel.predict(image) { (imageBuffer, error) in
      XCTAssertNotNil(imageBuffer)
      exp.fulfill()
    }
    wait(for: exp)
  }

  func testAllModelsFritzWrapped() {
    for model in allModels {
      XCTAssertTrue(FritzMLModel.self == type(of: model.model))
    }
  }

  func testStyleModelEnumeration() {
    let image = TestImage.indoor.fritzImage
    for style in PaintingStyleModel.Style.allCases {

      let exp = XCTestExpectation(description: "The model runs")
      style.build().predict(image) { (imageBuffer, error) in
        XCTAssertNotNil(imageBuffer)
        exp.fulfill()
      }
      wait(for: exp)
    }
    for style in PaintingStyleModel.Style.allCases {

      let exp = XCTestExpectation(description: "The model runs")
      style.build().predict(image) { (imageBuffer, error) in
        XCTAssertNotNil(imageBuffer)
        exp.fulfill()
      }
      wait(for: exp)
    }
  }

  func testLoadingFromManagedModel() {
    let model = PaintingStyleModel.Style.theTrial.build()
    let storedModel = model.managedModel.loadModel()
    XCTAssertNotNil(storedModel)
  }
}
