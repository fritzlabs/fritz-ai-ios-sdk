//
//  HumanPoseSmall.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@objc(FritzVisionHumanPoseModelSmall)
@available(iOS 12.0, *)
public final class FritzVisionHumanPoseModelSmall: FritzVisionHumanPosePredictor, DownloadableModel
{
  /// Model Configuration for pose model in Fritz.
  @objc public static var modelConfig: FritzModelConfiguration = FritzModelConfiguration(
    identifier: "22ea52e3fc1b441d8b80906f912a6af4",
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
    completionHandler: @escaping (FritzVisionHumanPoseModelSmall?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
