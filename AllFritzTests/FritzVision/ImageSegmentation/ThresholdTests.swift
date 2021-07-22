//
//  ThresholdTests.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 11/19/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzVision

class ThresholdTests: XCTestCase {

  func testThreshold() {
    let count = 10
    var array = [Float](repeating: 0, count: count)
    for i in 0..<count {
      array[i] = Float(i)
    }

    var output = [Float](repeating: 0, count: count)

    let expected: [Float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0]
    arrayThreshold(&array, &output, 5.0, count)
    XCTAssertEqual(output, expected)
  }

  func testArgmax() {
    let count = 2
    var input: [Float] = [0.0, 1.0, 0.5, 0.8]

    var output = [Int32](repeating: 0, count: count)

    let expected: [Int32] = [1, 0]

    let numClasses = 2
    argmax(&input, &output, 0.0, numClasses, count)
    XCTAssertEqual(output, expected)
  }
}
