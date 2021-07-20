//
//  PeopleAndPetAccurate.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Image segmentation model to detect people and pets.
@available(iOS 11.0, *)
@objc(FritzVisionPeopleAndPetSegmentationModelAccurate)
public final class FritzVisionPeopleAndPetSegmentationModelAccurate: FritzVisionPeopleAndPetSegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "996011d930ad4a0791f02349f0971039",
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
    completionHandler: @escaping (FritzVisionPeopleAndPetSegmentationModelAccurate?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
