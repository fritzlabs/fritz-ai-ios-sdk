//
//  LabelModelFast.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@objc(FritzVisionLabelModelFast)
@available(iOS 11.0, *)
public final class FritzVisionLabelModelFast: FritzVisionLabelPredictor, DownloadableModel {

  @objc public static var modelConfig: FritzModelConfiguration = FritzModelConfiguration(
    identifier: "88e28aa99ea94c9a96c5aff175a84b16",
    version: 3,
    pinnedVersion: 3
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
    completionHandler: @escaping (FritzVisionLabelModelFast?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
