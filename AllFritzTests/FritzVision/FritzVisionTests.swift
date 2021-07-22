//
//  FritzVisionTests.swift
//  FritzVisionTests
//
//  Created by Christopher Kelly on 6/11/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzVision

class FritzVisionCroppingTests: XCTestCase {
  let testAssets = TestAssets()

  func testCenterCropSquare() {
    let image = TestImage.indoor.fritzImage
    let results = FritzVisionCropAndScale.getCenterCropRect(forImageToScaleSize: image.size)
    let expected = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.width)
    XCTAssertEqual(results, expected)
  }

  func testCenterCropTall() {
    let image = TestImage.indoorTall.fritzImage
    let results = FritzVisionCropAndScale.getCenterCropRect(forImageToScaleSize: image.size)
    let expected = CGRect(
      x: 0,
      y: (image.size.height - image.size.width) / 2,
      width: image.size.width,
      height: image.size.width
    )
    XCTAssertEqual(results, expected)
  }

  func testCenterCropWide() {
    let image = TestImage.indoorWide.fritzImage
    let results = FritzVisionCropAndScale.getCenterCropRect(forImageToScaleSize: image.size)
    let expected = CGRect(
      x: (image.size.width - image.size.height) / 2,
      y: 0,
      width: image.size.height,
      height: image.size.height
    )
    XCTAssertEqual(results, expected)
  }

  func testImageResizingSameFlippedAspectRatio() {
    var image = TestImage.indoorWide.fritzImage
    var resized = image.resized(withMaxDimensionLessThan: 150)!
    XCTAssertEqual(resized.size.width, 150)
    var original = image.originalSize.width / image.originalSize.height
    var new = resized.originalSize.width / resized.originalSize.height
    XCTAssertEqual(original, new, accuracy: 0.03)

    image = TestImage.indoorTall.fritzImage
    resized = image.resized(withMaxDimensionLessThan: 150)!
    XCTAssertEqual(resized.size.height, 150)
    original = image.originalSize.width / image.originalSize.height
    new = resized.originalSize.width / resized.originalSize.height
    XCTAssertEqual(original, new, accuracy: 0.03)
  }

  func testImageResizingSmallerThanRequested() {
    let image = TestImage.indoorWide.fritzImage
    let resized = image.resized(withMaxDimensionLessThan: 400)!
    XCTAssertEqual(image.size, resized.size)
  }

}
