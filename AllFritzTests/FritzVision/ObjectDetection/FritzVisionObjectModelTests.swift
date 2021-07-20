//
//  FritzVisionObjectModelTests.swift
//  FritzVisionObjectModelTests
//
//  Created by Christopher Kelly on 7/5/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzVisionObjectModelFast

extension coke_detector: SwiftIdentifiedModel {
  static let modelIdentifier = "test"
  static let packagedModelVersion = 1
}

extension YOLOv3TinyInt8LUT: SwiftIdentifiedModel {
  static let modelIdentifier = "YOLO"
  static let packagedModelVersion = 1
}

class FritzVisionObjectModelTestCase: FritzTestCase {

  // TODO: Right now, this is technically hitting production.  However, since none of the
  // tests will last long enough to send a request that is relevant, it won't actually
  // affect anything. Once we split up how sessions load, we'll be able to specify this
  // to hit a test target.
  lazy var fritzVision = FritzVisionObjectModelFast()

  func loadImage() -> UIImage {
    let bundle = Bundle(for: type(of: self))
    let path = bundle.path(forResource: "testImage", ofType: "png")!
    return UIImage(contentsOfFile: path)!
  }

  func testWrappingFritzCorrectly() {
    // XCTAssertTrue(FritzMLModel.self == type(of: fritzVision.model.model))
  }

  func testPredictUIImage() {
    let image = TestImage.indoor.fritzImage
    let expectedLabels = [
      "chair", "tv",
    ]
    let objects = try! fritzVision.predict(image)
    XCTAssertEqual(expectedLabels, objects.map { value in value.label })
  }

  func testPredictUIImageLimitResults() {
    let image = TestImage.indoor.fritzImage
    let expectedLabels = [
      "chair",
    ]
    let options = FritzVisionObjectModelOptions()
    options.numResults = 1
    let objects = try! fritzVision.predict(image, options: options)
    XCTAssertEqual(expectedLabels, objects.map { value in value.label })
  }

  func testPredictUIImageChangeConfidence() {
    let image = TestImage.indoor.fritzImage

    // Fewer predictions with stricter confidence
    let highConfidenceLabels = ["chair"]
    let options = FritzVisionObjectModelOptions()
    options.threshold = 0.8
    let highObjects = try! fritzVision.predict(image, options: options)
    fritzVision.record(image, predicted: highObjects)
    XCTAssertEqual(highConfidenceLabels, highObjects.map { value in value.label })

    // More predictions with looser confidence
    let expectedLabels = ["chair", "tv", "potted plant", "chair", "vase", "vase"]
    options.threshold = 0.3
    let lowObjects = try! fritzVision.predict(image, options: options)
    XCTAssertEqual(expectedLabels, lowObjects.map { value in value.label })
  }

  func skipped_testCustomModel() {
    let fritzImage = TestImage.coke.fritzImage
    let customModel = FritzVisionObjectModelFast(
      identifiedModel: try! coke_detector(configuration: MLModelConfiguration()),
      classNames: ["Coke"]
    )
    let result = try! customModel.predict(fritzImage)
    XCTAssertTrue(result.count > 0)
  }

  func testCustomProcessedModelWithoutLabels() {
    let fritzImage = TestImage.indoor.fritzImage
    let customModel = FritzVisionObjectModelFast(model: try! YOLOv3TinyInt8LUT(configuration: MLModelConfiguration()))
    let result = try! customModel.predict(fritzImage)
    XCTAssertTrue(result.count > 0)
  }

  func testCustomProcessedModelLowThresholds() {
    let fritzImage = TestImage.indoor.fritzImage
    let customModel = FritzVisionObjectModelFast(model: try! YOLOv3TinyInt8LUT(configuration: MLModelConfiguration()))
    let options = FritzVisionObjectModelOptions()
    options.threshold = 0.0001
    options.iouThreshold = 0.8
    options.numResults = 100
    let result = try! customModel.predict(fritzImage, options: options)
    XCTAssertEqual(100, result.count)
  }
}
