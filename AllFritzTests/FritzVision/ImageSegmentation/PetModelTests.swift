//
//  PetModelTests.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 5/15/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import FritzVisionPetSegmentationModelFast
import XCTest

class FritzVisionPetSegmentationModelTests: FritzTestCase {
  lazy var petModel = FritzVisionPetSegmentationModelFast()

  func testPetPrediction() {
    let cat = TestImage.cat.fritzImage
    
    let segmentationResult = try! petModel.predict(cat)
    let classesArray = segmentationResult.getArrayOfMostLikelyClasses()
    var total: Int32 = 0
    for val in classesArray {
      total += val
    }

    // Total pixels below from previous run of working model.
    let expectedTotalCatPixels: Int32 = 21877
    XCTAssertEqual(Float(expectedTotalCatPixels), Float(total), accuracy: 10.0)

    let expectedEvents: [SessionEvent.EventType] = [
      .modelInstalled,
      .prediction,
    ]
    XCTAssertEqual(self.trackedEventTypes(), expectedEvents)
  }
}
