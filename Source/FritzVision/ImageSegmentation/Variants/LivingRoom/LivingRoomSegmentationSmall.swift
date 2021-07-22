//
//  LivingRoomSegmentationSmall.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Image segmentation model to detect common living room objects.
@available(iOS 12.0, *)
@objc(FritzVisionLivingRoomSegmentationModelSmall)
public final class FritzVisionLivingRoomSegmentationModelSmall: FritzVisionLivingRoomSegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "121c8c05c49d490aa94e1507c90c6a7d",
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
    completionHandler: @escaping (FritzVisionLivingRoomSegmentationModelSmall?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
