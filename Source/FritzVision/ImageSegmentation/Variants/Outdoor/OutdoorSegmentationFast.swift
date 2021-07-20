//
//  OutdoorSegmentationFast.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Image segmentation model to detect common outdoor objects.
@available(iOS 11.0, *)
@objc(FritzVisionOutdoorSegmentationModelFast)
public final class FritzVisionOutdoorSegmentationModelFast: FritzVisionOutdoorSegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "f7eb11b912224da9b7d4840a1749a4c2",
    version: 3,
    pinnedVersion: 3
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
    completionHandler: @escaping (FritzVisionOutdoorSegmentationModelFast?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
