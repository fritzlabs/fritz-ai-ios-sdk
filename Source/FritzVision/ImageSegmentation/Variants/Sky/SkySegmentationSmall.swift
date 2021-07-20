//
//  SkySegmentationSmall.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Image segmentation model to detect the sky.
@available(iOS 12.0, *)
@objc(FritzVisionSkySegmentationModelSmall)
public final class FritzVisionSkySegmentationModelSmall: FritzVisionSkySegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "de1cb6ec3d8a4f0792f9907eeb55438e",
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
    completionHandler: @escaping (FritzVisionSkySegmentationModelSmall?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
