//
//  FritzVisionPeopleSegmentationModelFastBase.swift
//  FritzVisionPeopleSegmentationModelFastBase
//
//  Created by Christopher Kelly on 1/23/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Image segmentation model to detect people.
@available(iOS 11.0, *)
@objc(FritzVisionPeopleSegmentationModelFast)
public final class FritzVisionPeopleSegmentationModelFast: FritzVisionPeopleSegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "438a0e2c1c1c4a449b1a708dbb309e06",
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
    completionHandler: @escaping (FritzVisionPeopleSegmentationModelFast?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
