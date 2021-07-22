//
//  OutdoorSegmentationSmall.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Image segmentation model to detect common outdoor objects.
@available(iOS 12.0, *)
@objc(FritzVisionOutdoorSegmentationModelSmall)
public final class FritzVisionOutdoorSegmentationModelSmall: FritzVisionOutdoorSegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "56185d8deb8f4dd0bcc7ac716fc39285",
    version: 2,
    pinnedVersion: 2
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
    completionHandler: @escaping (FritzVisionOutdoorSegmentationModelSmall?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
