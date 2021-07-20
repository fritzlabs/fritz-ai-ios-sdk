//
//  FritzVisionPoseLiftingModel+Downloadable.swift
//  FritzVisionMultiPoseModel
//
//  Created by Christopher Kelly on 4/9/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

// Adding in the pose lifting model into the test bundle because I don't want to include it in
// FritzVision.
@available(iOS 11.0, *)
extension poseLifter: SwiftIdentifiedModel {
  static let modelIdentifier = FritzVisionPoseLiftingModel.modelConfig.identifier
  static let packagedModelVersion = FritzVisionPoseLiftingModel.modelConfig.version
}

@available(iOS 11.0, *)
extension FritzVisionPoseLiftingModel: DownloadableModel {

  /// Model Configuration for pose model in Fritz.
  public static var modelConfig: FritzModelConfiguration = FritzModelConfiguration(
    identifier: "9631a83a38f94d7096d74efc12d5d3d3",
    version: 3
  )

  public static var managedModel: FritzManagedModel {
    return FritzManagedModel(modelConfig: FritzVisionPoseLiftingModel.modelConfig)
  }

  /// Is WiFi required to download pose model over the air.
  public static var wifiRequiredForModelDownload: Bool = _wifiRequiredForModelDownload

  /// Fetch model. Downloads model if model has not been downloaded before.
  ///
  /// - Parameter completionHandler: CompletionHandler called after fetchModel request finishes.
  public static func fetchModel(
    completionHandler: @escaping (FritzVisionPoseLiftingModel?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}

@available(iOS 12.0, *)
extension FritzVisionPoseLiftingModel: PackagedModelType {
  public convenience init() {
    let model = try! poseLifter(configuration: MLModelConfiguration())
    self.init(model: model)
  }
}

@available(iOS 12.0, *)
@objc(FritzVisionPoseLiftingModelObjc)
public class FritzVisionPoseLiftingModelObjc: NSObject {

  @objc public static var model: FritzVisionPoseLiftingModel {
    return FritzVisionPoseLiftingModel()
  }
}
