//
//  FritzVisionPeopleSegmentationModelAccurateBase.swift
//  FritzVisionPeopleSegmentationModelAccurateBase
//
//  Created by Christopher Kelly on 1/24/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Image segmentation model to detect people.
@available(iOS 11.0, *)
@objc(FritzVisionPeopleSegmentationModelAccurate)
public final class FritzVisionPeopleSegmentationModelAccurate: FritzVisionPeopleSegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "d470196ca5a04457ae0644a50fc654b7",
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
    completionHandler: @escaping (FritzVisionPeopleSegmentationModelAccurate?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
