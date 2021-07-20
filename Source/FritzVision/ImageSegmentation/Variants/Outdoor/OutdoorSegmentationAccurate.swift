//
//  OutdoorSegmentationAccurate.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Image segmentation model to detect common outdoor objects.
@available(iOS 11.0, *)
@objc(FritzVisionOutdoorSegmentationModelAccurate)
public final class FritzVisionOutdoorSegmentationModelAccurate: FritzVisionOutdoorSegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "0aacc463445448f4b5bb2591495e6eca",
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
    completionHandler: @escaping (FritzVisionOutdoorSegmentationModelAccurate?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
