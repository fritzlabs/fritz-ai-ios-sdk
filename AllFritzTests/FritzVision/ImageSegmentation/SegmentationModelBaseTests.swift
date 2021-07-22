//
//  FritzVisionSegmentationPredictorTests.swift
//  FritzVisionSegmentationPredictorTests
//
//  Created by Christopher Kelly on 9/24/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import FritzVision
import XCTest

@testable import FritzVisionPeopleSegmentationModelFast

class FritzVisionSegmentationPredictorTests: FritzTestCase {

  func testPredictsWithFritzPredictions() {
    let peopleModel = try! people_segmentation_mobilenet_256x256_75_1568480498(configuration: MLModelConfiguration())
    let visionModel = FritzVisionSegmentationPredictor(
      model: peopleModel,
      classes: FritzVisionPeopleClass.allClasses
    )

    let image = TestImage.indoor.fritzImage

    visionModel.predict(image) { result, error in
      if let _ = error {
        XCTFail("Error in fritz vision predict")
      }
    }
    let expectedEvents: [SessionEvent.EventType] = [
      .modelInstalled,
      .prediction,
    ]
    XCTAssertEqual(self.trackedEventTypes(), expectedEvents)
  }

  func testResize() {
    let image = TestImage.person.fritzImage
    let output = image.prepare(size: CGSize(width: 100, height: 100))
    XCTAssertNotNil(output)
  }

  func testRotate() {
    let image = TestImage.person.fritzImage
    image.metadata = FritzVisionImageMetadata()
    image.metadata?.orientation = FritzImageOrientation(.right)
    let output = image.prepare(size: CGSize(width: 100, height: 100))
    XCTAssertNotNil(output)
  }

  func testCenterCrop() {
    let image = TestImage.blonde.fritzImage
    image.metadata = FritzVisionImageMetadata()
    image.metadata?.orientation = FritzImageOrientation(.right)
    let output = image.prepare(size: CGSize(width: 100, height: 100), scaleCropOption: .centerCrop)
    XCTAssertNotNil(output)
  }

  func testClassNamesInMetadata() {
    let model = try! FaceMasks(configuration: MLModelConfiguration())
    let visionModel = FritzVisionSegmentationPredictor(model: model)
    XCTAssertEqual(visionModel.classes.count, 2)
    XCTAssertEqual(visionModel.classes[0].color.a, 0)
  }

  func testLabelColor() {
    let peopleModel = try! people_segmentation_mobilenet_256x256_75_1568480498(configuration: MLModelConfiguration())
    let visionModel = FritzVisionSegmentationPredictor(
      model: peopleModel,
      classes: FritzVisionOutdoorClass.allClasses
    )
    for segmentationClass in visionModel.classes {
      if segmentationClass.label != "None" {
        // If alpha is 255, a color was successfully picked
        XCTAssertEqual(segmentationClass.color.a, 255)
      }
    }
  }
}
