//
//  LivingRoomSegmentationFast.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Image segmentation model to detect common living room objects.
@available(iOS 11.0, *)
@objc(FritzVisionLivingRoomSegmentationModelFast)
public final class FritzVisionLivingRoomSegmentationModelFast: FritzVisionLivingRoomSegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "409c9c87ae6b47eb9f861ee0c6f85753",
    version: 5,
    pinnedVersion: 5
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
    completionHandler: @escaping (FritzVisionLivingRoomSegmentationModelFast?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
