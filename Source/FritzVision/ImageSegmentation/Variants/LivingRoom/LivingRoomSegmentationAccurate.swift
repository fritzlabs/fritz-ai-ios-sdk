//
//  LivingRoomSegmentationAccurate.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Image segmentation model to detect common living room objects.
@available(iOS 11.0, *)
@objc(FritzVisionLivingRoomSegmentationModelAccurate)
public final class FritzVisionLivingRoomSegmentationModelAccurate: FritzVisionLivingRoomSegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "40e3dde2d9104e2283591c863967b1cc",
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
    completionHandler: @escaping (FritzVisionLivingRoomSegmentationModelAccurate?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
