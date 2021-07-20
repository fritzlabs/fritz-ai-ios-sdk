//
//  AnnotationRecordingTestCase.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 11/19/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import Hippolyte
import FritzVision
import FritzVisionHumanPoseModelFast
import FritzVisionObjectModelFast
import FritzVisionLabelModelFast
import XCTest

class AnnotationPoseRecordingTestCase: FritzMockedRequestTestCase {
  func testDecodeRocketbook() {
    // enable annotations
    let modifiedSettings = SessionSettings(
      recordAnnotationsEnabled: true, annotationRequestBatchSize: 0
    )
    updateSessionSettings(modifiedSettings)
    Hippolyte.shared.add(stubbedRequest: requestStubs.annotationRecordings())
    FritzCore.configuration.sessionManager.loadSessionSettings()
    let model = RocketbookPoseModel()
    model.useDisplacements = false
    let exp = XCTestExpectation(description: "Assert recordings endpoint called after recording.")

    let expectedURL = RequestStub.FritzTestUrl.annotationRecordings.fullURL
    let task = URLSession.shared.dataTask(with: expectedURL) { data, _, _ in
      exp.fulfill()
    }
    task.resume()

    let image = TestImage.rocketbook.fritzImage
    let poses = try! model.predict(image).poses(limit: 1)
    let recording = model.record(image, predicted: poses, modified: poses)!
    let inputWidth = recording.data["input_width"] as! CGFloat
    let inputHeight = recording.data["input_height"] as! CGFloat
    XCTAssertEqual(inputWidth, 750)
    XCTAssertEqual(inputHeight, 1000)

    let predictedAnnotations = recording.data["predicted_annotations"] as! Array<[String:Any]>
    XCTAssertEqual(1, predictedAnnotations.count)
    let modifiedAnnotations = recording.data["modified_annotations"] as! Array<[String:Any]>
    XCTAssertEqual(NotebookSkeleton.objectName, predictedAnnotations[0]["label"]! as! String)
    XCTAssertEqual(nil, predictedAnnotations[0]["bbox"] as? [String:CGFloat]?)
    XCTAssertEqual(false, predictedAnnotations[0]["is_image_label"]! as! Bool)
    XCTAssertEqual(NotebookSkeleton.objectName, modifiedAnnotations[0]["label"]! as! String)


    XCTAssertEqual(1, modifiedAnnotations.count)

    wait(for: exp)
  }

  func testHumanSkeletonKeypointNames() {
    // enable annotations
    let modifiedSettings = SessionSettings(
      recordAnnotationsEnabled: true, annotationRequestBatchSize: 0
    )
    updateSessionSettings(modifiedSettings)
    Hippolyte.shared.add(stubbedRequest: requestStubs.annotationRecordings())
    FritzCore.configuration.sessionManager.loadSessionSettings()
    let model = FritzVisionHumanPoseModelFast()
    model.useDisplacements = false
    let exp = XCTestExpectation(description: "Assert recordings endpoint called after recording.")

    let expectedURL = RequestStub.FritzTestUrl.annotationRecordings.fullURL
    let task = URLSession.shared.dataTask(with: expectedURL) { data, _, _ in
      exp.fulfill()
    }
    task.resume()

    let image = TestImage.family.fritzImage
    let poses = try! model.predict(image).poses(limit: 1)
    let recording = model.record(image, predicted: poses, modified: poses)!
    
    let predictedAnnotations = recording.data["predicted_annotations"] as! Array<[String:Any]>
    let keypoints = predictedAnnotations[0]["keypoints"] as! Array<[String:Any]>
    XCTAssertEqual(keypoints[0]["label"]! as! String, "nose")
    wait(for: exp)
  }

  func testRecordingAnnotationsSerializable() {
    let model = RocketbookPoseModel()
    model.useDisplacements = false
    let image = TestImage.rocketbook.fritzImage
    let poses = try! model.predict(image).poses(limit: 1)
    let recording = model.record(image, predicted: poses, modified: poses)!
    let data = try? JSONSerialization.data(withJSONObject: recording.data, options: [])
    XCTAssertNotNil(data)
  }

  func testObjectDetectionSerializable() {
    let model = FritzVisionObjectModelFast()


    let image = TestImage.indoor.fritzImage

    let objects = try! model.predict(image)
    let recording = model.record(image, predicted: objects)!
    let data = try? JSONSerialization.data(withJSONObject: recording.data, options: [])
    XCTAssertNotNil(data)
  }

  func testImageLabelingSerializable() {
    // enable annotations
    let modifiedSettings = SessionSettings(
      recordAnnotationsEnabled: true, annotationRequestBatchSize: 0
    )
    updateSessionSettings(modifiedSettings)
    Hippolyte.shared.add(stubbedRequest: requestStubs.annotationRecordings())
    FritzCore.configuration.sessionManager.loadSessionSettings()

    let model = FritzVisionLabelModelFast()

    let exp = XCTestExpectation(description: "Assert recordings endpoint called after recording.")
    let expectedURL = RequestStub.FritzTestUrl.annotationRecordings.fullURL
    let task = URLSession.shared.dataTask(with: expectedURL) { data, _, _ in
      exp.fulfill()
    }
    task.resume()

    let image = TestImage.cat.fritzImage

    let options = FritzVisionLabelModelOptions()
    options.threshold = 0.01
    let labels = try! model.predict(image, options: options)

    let recording = model.record(image, predicted: labels)!
    let inputWidth = recording.data["input_width"] as! CGFloat
    let inputHeight = recording.data["input_height"] as! CGFloat
    XCTAssertEqual(inputWidth, 1000)
    XCTAssertEqual(inputHeight, 667)

    let predictedAnnotations = recording.data["predicted_annotations"] as! Array<[String:Any]>
    XCTAssertEqual(3, predictedAnnotations.count)

    XCTAssertEqual(true, predictedAnnotations[0]["is_image_label"]! as! Bool)
    XCTAssertEqual(labels[0].label, predictedAnnotations[0]["label"]! as! String)

    wait(for: exp)
  }

  func testImageSegmentationSerializable() {
    let modifiedSettings = SessionSettings(recordAnnotationsEnabled: true, annotationRequestBatchSize: 0)
    updateSessionSettings(modifiedSettings)
    Hippolyte.shared.add(stubbedRequest: requestStubs.annotationRecordings())
    FritzCore.configuration.sessionManager.loadSessionSettings()
    
    let model = FritzVisionPeopleSegmentationModelFast()
    
    let exp = XCTestExpectation(description: "Assert recordings endpoint called after recording.")
    let expectedURL = RequestStub.FritzTestUrl.annotationRecordings.fullURL
    let task = URLSession.shared.dataTask(with: expectedURL) { data, _, _ in exp.fulfill() }
    task.resume()
    
    let image = TestImage.person.fritzImage
    
    let result = try! model.predict(image)
    let recording = model.record(image, predicted: result.segmentationMasks(), modified: result.segmentationMasks(confidenceThreshold: 0.5, areaThreshold: 0.99))!
    let predictedAnnotations = recording.data["predicted_annotations"] as! Array<[String:Any]>
    // There should only be annotations for the people class. Background "None" class is filtered out.
    XCTAssertEqual(1, predictedAnnotations.count)
    XCTAssertNotNil(predictedAnnotations[0]["segmentation"])
    // We should have filtered out all of the annotations with the area threshold for user modified
    let modifiedAnnotations = recording.data["modified_annotations"] as! Array<[String:Any]>
    XCTAssertEqual(0, modifiedAnnotations.count)
    
  }
  
  func testMaskArrayAs2D() {
    let array: [Float] = Array(repeating: 0, count: 100)
    XCTAssertNoThrow(try array.as2D(width: 10, height: 10))
    XCTAssertThrowsError(try array.as2D(width: 5, height: 5))
  }

}
