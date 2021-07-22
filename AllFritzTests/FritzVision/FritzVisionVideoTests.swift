//
//  FritzVisionVideoTests.swift
//  AllFritzTests
//
//  Created by Steven Yeung on 10/27/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import XCTest

@testable import FritzVision
@testable import FritzVisionStyleModelPaintings
@testable import FritzVisionStyleModelPatterns

class FritzVisionVideoTests: FritzTestCase {

  let testVideo = TestAssets().getFaceVideo()
  lazy var hairModel = FritzVisionHairSegmentationModelFast()
  lazy var peopleModel = FritzVisionPeopleSegmentationModelFast()
  lazy var objectModel = FritzVisionObjectModelFast()
  lazy var poseModel = FritzVisionHumanPoseModelFast()
  lazy var sprinklesModel = PatternStyleModel.Style.sprinkles.build()
  lazy var starryNightModel = PaintingStyleModel.Style.starryNight.build()

  func testFrameNoFilter() {
    let fritzVideo = FritzVisionVideo(url: testVideo)
    let frame = fritzVideo.frame(at: 1)
    let image = frame?.image
    XCTAssertNotNil(image)
  }

  public func testStitch() {
    let fritzVideo = FritzVisionVideo(url: testVideo)
    let startDuration = fritzVideo.duration
    try? fritzVideo.stitch(with: fritzVideo.player.currentItem!.asset)
    let endDuration = fritzVideo.duration
    XCTAssertTrue(endDuration > startDuration)
  }

  func testInvalidFrame() {
    let fritzVideo = FritzVisionVideo(url: testVideo)
    let frame = fritzVideo.frame(at: 100)
    XCTAssertNil(frame)
  }

  func testFrameHair() {
    let filter = FritzVisionBlendHairCompoundFilter(model: hairModel)
    let fritzVideo = FritzVisionVideo(url: testVideo, withFilter: filter)
    let frame = fritzVideo.frame(at: 1)
    let image = frame?.image
    XCTAssertNotNil(image)
  }

  func testFrameStyle() {
    let filter = FritzVisionStylizeImageCompoundFilter(model: sprinklesModel)
    let fritzVideo = FritzVisionVideo(url: testVideo, withFilter: filter)
    let frame = fritzVideo.frame(at: 1)
    let image = frame?.image
    XCTAssertNotNil(image)
  }

  func testFrameObjectDetection() {
    let filter = FritzVisionDrawBoxesCompoundFilter(model: objectModel)
    let fritzVideo = FritzVisionVideo(url: testVideo, withFilter: filter)
    let frame = fritzVideo.frame(at: 3)
    let image = frame?.image
    XCTAssertNotNil(image)
  }

  func testFrameNoValidPose() {
    let filter = FritzVisionDrawSkeletonCompoundFilter(model: poseModel)
    let fritzVideo = FritzVisionVideo(url: testVideo, withFilter: filter)
    let frame = fritzVideo.frame(at: 1)
    let image = frame?.image
    // Valid output despite no pose being predicted
    XCTAssertNotNil(image)
  }

  func testFrameDualStyle() {
    let filters = [
      FritzVisionStylizeImageCompoundFilter(model: sprinklesModel),
      FritzVisionStylizeImageCompoundFilter(model: starryNightModel)
    ]
    let fritzVideo = FritzVisionVideo(url: testVideo, applyingFilters: filters)
    let frame = fritzVideo.frame(at: 3)
    let image = frame?.image
    XCTAssertNotNil(image)
  }

  func testFrameBuildAndOverlay() {
    let peopleOptions = FritzVisionSegmentationMaskOptions()
    peopleOptions.maskColor = .gray
    let filters: [FritzVisionImageFilter] = [
      FritzVisionBlendHairCompoundFilter(model: hairModel),
      FritzVisionDrawBoxesCompoundFilter(model: objectModel),
      FritzVisionMaskPeopleOverlayFilter(model: peopleModel, options: peopleOptions)
    ]
    let fritzVideo = FritzVisionVideo(url: testVideo, applyingFilters: filters)
    let frame = fritzVideo.frame(at: 3)
    let image = frame?.image
    XCTAssertNotNil(image)
  }

  func testInvalidMultipleFrames() {
    let exp = XCTestExpectation(description: "Invalid frames")
    let fritzVideo = FritzVisionVideo(url: testVideo)
    XCTAssertTrue(fritzVideo.duration >= 4)
    let timeStamps = [1.0, 100.0, 2.0]
    var collectedFrames: [FritzVisionImage] = []
    var errorCount = 0
    fritzVideo.frames(at: timeStamps) { response in
      switch response {
      case .success(let image):
        collectedFrames.append(image)
      case .failure(let error):
        XCTAssertEqual(error, FritzVisionVideoError.incompleteExtraction)
        errorCount += 1
      }
      if collectedFrames.count == 2 {
        exp.fulfill()
      }
    }
    wait(for: exp)
    XCTAssertEqual(collectedFrames.count, 2)
    XCTAssertEqual(errorCount, 1)
  }

  func testMultipleFrames() {
    let exp = XCTestExpectation(description: "Extract frames")
    let filter = FritzVisionBlendHairCompoundFilter(model: hairModel)
    let fritzVideo = FritzVisionVideo(url: testVideo, withFilter: filter)
    XCTAssertTrue(fritzVideo.duration >= 4)
    let timeStamps = [1.0, 1.6, 3.7, 4.4]
    var collectedFrames: [FritzVisionImage] = []
    fritzVideo.frames(at: timeStamps) { response in
      switch response {
      case .success(let image):
        collectedFrames.append(image)
      case .failure:
        XCTFail()
      }
      if collectedFrames.count == 4 {
        exp.fulfill()
      }
    }
    wait(for: exp)
    XCTAssertEqual(collectedFrames.count, 4)
    for frame in collectedFrames {
      let image = frame.image
      XCTAssertNotNil(image)
    }
  }

  func testViewSeek() {
    let fritzVideo = FritzVisionVideo(url: testVideo)
    let videoView = FritzVideoView(source: fritzVideo)
    videoView.seek(to: 3.6)

    let videoTime = fritzVideo.player.currentTime()
    XCTAssertEqual(videoTime.seconds, 3.6)
  }

  func testViewPlaying() {
    let fritzVideo = FritzVisionVideo(url: testVideo)
    let videoView = FritzVideoView(source: fritzVideo)
    XCTAssertFalse(videoView.isPlaying)
    videoView.play()
    XCTAssertTrue(videoView.isPlaying)
  }
}
