//
//  HumanPoseFast.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
@objc(FritzVisionHumanPoseModelFast)
public final class FritzVisionHumanPoseModelFast: FritzVisionHumanPosePredictor, DownloadableModel {
  /// Model Configuration for pose model in Fritz.
  @objc public static var modelConfig: FritzModelConfiguration = FritzModelConfiguration(
    identifier: "2ad3270b39734a15a0b1fe3bd1ab000e",
    version: 2,
    pinnedVersion: 2
  )

  @objc public static var managedModel: FritzManagedModel {
    return modelConfig.buildManagedModel()
  }

  /// Is WiFi required to download pose model over the air.
  @objc public static var wifiRequiredForModelDownload: Bool = _wifiRequiredForModelDownload

  /// Fetch model. Downloads model if model has not been downloaded before.
  ///
  /// - Parameter completionHandler: CompletionHandler called after fetchModel request finishes.
  public static func fetchModel(
    completionHandler: @escaping (FritzVisionHumanPoseModelFast?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
