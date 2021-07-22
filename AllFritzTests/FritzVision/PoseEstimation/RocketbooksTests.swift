//
//  RocketbooksTests.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 8/29/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import XCTest

@testable import FritzVision

class RocketbooksPoseTestCase: FritzTestCase {

  func testDecodeRocketbook() {
    let model = RocketbookPoseModel()
    model.useDisplacements = false
    let options = FritzVisionPoseModelOptions()
    options.minPartThreshold = 0.1
    options.minPoseThreshold = 0.5
    var image = TestImage.rocketbook.fritzImage
    image = FritzVisionImage(imageBuffer: image.prepare(size: CGSize(width: 200, height: 260))!)
    let posePrediction = try! model.predict(image, options: options)
    let poses = posePrediction.poses(limit: 1)
    let _ = image.draw(poses: poses)
  }

  func testDecodeRocketbookDisplacements() {
    let model = RocketbookPoseModel()
    model.useDisplacements = true
    let options = FritzVisionPoseModelOptions()
    options.minPartThreshold = 0.1
    options.minPoseThreshold = 0.5
    var image = TestImage.rocketbook.fritzImage
    image = FritzVisionImage(imageBuffer: image.prepare(size: CGSize(width: 200, height: 260))!)
    let posePrediction = try! model.predict(image, options: options)
    let poses = posePrediction.poses(limit: 1)
    let _ = image.draw(poses: poses)
  }

}

public enum NotebookSkeleton: Int, SkeletonType {

  public static let objectName: String = "Notebook"
  case topLeft
  case bottomLeft
  case bottomRight
  case topRight

  public static let connectedParts: [ConnectedPart<NotebookSkeleton>] = [
    (.topLeft, .bottomLeft),
    (.bottomLeft, .bottomRight),
    (.bottomRight, .topRight),
    (.topRight, .topLeft),
  ]

  public static let poseChain: [ConnectedPart<NotebookSkeleton>] = [
    (.topLeft, .bottomLeft),
    (.bottomLeft, .bottomRight),
    (.bottomRight, .topRight),
  ]
}

extension pose_mobilenet_260x200_5_8_large_1567123257: SwiftIdentifiedModel {
  static let modelIdentifier = RocketbookPoseModel.modelConfig.identifier
  static let packagedModelVersion = 3
}  // The model inputs and outputs conform to those expected by the FritzVIsionCustomPoseModel class.
// This means that we can use all of Fritz's pre- and pose-processing helpers to work with
// model inputs and outputs. We can also set options controlling when new models are
// downloaded to users.
@available(iOS 11.0, *)
public final class RocketbookPoseModel: FritzVisionPosePredictor<NotebookSkeleton>,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "27ff5713fe94417087c327622d26deed",
    version: 1
  )

  @objc public static var managedModel: FritzManagedModel {
    return modelConfig.buildManagedModel()
  }

  @objc public static var wifiRequiredForModelDownload: Bool = _wifiRequiredForModelDownload

  public static func fetchModel(completionHandler: @escaping (RocketbookPoseModel?, Error?) -> Void)
  {
    _fetchModel(completionHandler: completionHandler)
  }

  public convenience init() {
    let model = try! pose_mobilenet_260x200_5_8_large_1567123257(configuration: MLModelConfiguration()).fritzModel()
    self.init(model: model)
  }
}
