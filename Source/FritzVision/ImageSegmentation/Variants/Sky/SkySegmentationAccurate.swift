//
//  SkySegmentationAccurate.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Image segmentation model to detect the sky.
@available(iOS 11.0, *)
@objc(FritzVisionSkySegmentationModelAccurate)
public final class FritzVisionSkySegmentationModelAccurate: FritzVisionSkySegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "1becd3909ab741269d82a471b6a8cbd6",
    version: 4,
    pinnedVersion: 4
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
    completionHandler: @escaping (FritzVisionSkySegmentationModelAccurate?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
