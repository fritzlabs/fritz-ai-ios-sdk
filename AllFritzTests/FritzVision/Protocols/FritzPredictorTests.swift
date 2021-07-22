//
//  FritzPredictorTests.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 4/2/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import FritzVision
import FritzVisionPeopleSegmentationModelFast
import XCTest

extension Array where Element == Int32 {
  fileprivate func sum() -> Int32 {
    var total: Int32 = 0
    for val in self {
      total += val
    }
    return total
  }

}

class FritzPredictorTests: FritzTestCase {

  func testPredictwithDirectResultReturnsSameResult() {
    // Testing to make sure that predicting both ways returns same result.
    let peoplePredictor = FritzVisionPeopleSegmentationModelFast()

    let image = TestImage.tennis.fritzImage
    
    var completionHandlerResult: FritzVisionSegmentationResult!

    peoplePredictor.predict(image) { result, error in
      completionHandlerResult = result!
    }
    let completionTotal = completionHandlerResult.getArrayOfMostLikelyClasses().sum()

    let directResult = try! peoplePredictor.predict(image)
    let directTotal = directResult.getArrayOfMostLikelyClasses().sum()
    XCTAssertEqual(completionTotal, directTotal)

  }
}
