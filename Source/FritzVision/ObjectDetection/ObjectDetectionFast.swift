//
//  ObjectDetectionFast.swift
//  FritzVision
//
//  Created by Christopher Kelly on 10/1/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@objc(FritzVisionObjectModelFast)
@available(iOS 12.0, *)
public final class FritzVisionObjectModelFast: FritzVisionObjectPredictor, DownloadableModel {

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "96ff1ce88e504504aa52d7cce6ae8cbb",
    version: 1,
    pinnedVersion: 1
  )

  @objc public static var managedModel: FritzManagedModel {
    return modelConfig.buildManagedModel()
  }

  @objc public static var wifiRequiredForModelDownload: Bool = _wifiRequiredForModelDownload

  /// Fetch model. Downloads model if model has not been downloaded before.
  ///
  /// - Parameter completionHandler: CompletionHandler called after fetchModel request finishes.
  @objc(fetchModelWithCompletionHandler:)
  public static func fetchModel(
    completionHandler: @escaping (FritzVisionObjectModelFast?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
