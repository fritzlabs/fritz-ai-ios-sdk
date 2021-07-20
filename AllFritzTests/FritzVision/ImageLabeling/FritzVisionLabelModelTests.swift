//
//  FritzVisionObjectModelTests.swift
//  FritzVisionObjectModelTests
//
//  Created by Christopher Kelly on 7/5/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import FritzVisionLabelModelFast
import XCTest

class FritzVisionLabelModelTestCase: FritzTestCase {
  // TODO: Right now, this is technically hitting production.  However, since none of the
  // tests will last long enough to send a request that is relevant, it won't actually
  // affect anything. Once we split up how sessions load, we'll be able to specify this
  // to hit a test target.
  lazy var fritzVision = FritzVisionLabelModelFast()

  func loadImage(forResource: String, ofType: String) -> UIImage {
    let bundle = Bundle(for: type(of: self))
    let path = bundle.path(forResource: forResource, ofType: ofType)!
    return UIImage(contentsOfFile: path)!
  }

  func testPredictUIImageOrientation() {
    let image = TestImage.tvRight.fritzImage
    image.metadata = FritzVisionImageMetadata()
    image.metadata?.orientation = .right

    let expectedLabels: [String] = ["home_theater"]
    let options = FritzVisionLabelModelOptions()
    options.threshold = 0.4

    let objects = try! fritzVision.predict(image, options: options)
    XCTAssertEqual(expectedLabels, objects.map { value in value.label })
  }

  func testPredictUIImage() {
    let image = TestImage.indoor.fritzImage
    let exp = XCTestExpectation(description: "persist model")

    let expectedLabels: [String] = []
    fritzVision.predict(image) { (objects, error) in
      guard let objects = objects else {
        XCTFail()
        return
      }
      XCTAssertEqual(expectedLabels, objects.map { value in value.label })
      exp.fulfill()
    }
    wait(for: exp)
  }

  func testPredictUIImageLimitResults() {
    let image = TestImage.indoor.fritzImage
    let options = FritzVisionLabelModelOptions()
    options.threshold = 0.1

    let expectedLabels: [String] = ["restaurant"]
    let objects = try! fritzVision.predict(image, options: options)
    XCTAssertEqual(expectedLabels, objects.map { value in value.label })
  }

  func testPredictUIImageLowerConfidence() {
    let image = TestImage.indoor.fritzImage
    let options = FritzVisionLabelModelOptions()
    options.threshold = 0.0
    options.numResults = 1

    let expectedLabels = [
      "restaurant",
    ]
    let objects = try! fritzVision.predict(image, options: options)
    XCTAssertEqual(expectedLabels, objects.map { value in value.label })
  }
}
