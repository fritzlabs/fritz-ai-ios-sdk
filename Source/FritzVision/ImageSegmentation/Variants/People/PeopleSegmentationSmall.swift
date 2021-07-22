//
//  FritzVisionPeopleSegmentationModelSmall.swift
//  FritzVisionPeopleSegmentationModelSmall
//
//  Created by Christopher Kelly on 1/23/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Image segmentation model to detect people.
@available(iOS 12.0, *)
@objc(FritzVisionPeopleSegmentationModelSmall)
public final class FritzVisionPeopleSegmentationModelSmall: FritzVisionPeopleSegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "d16cc6c93e9446d89fd097c8245c4b13",
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
    completionHandler: @escaping (FritzVisionPeopleSegmentationModelSmall?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
