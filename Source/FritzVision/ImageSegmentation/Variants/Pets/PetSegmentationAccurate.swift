//
//  FritzVisionPetSegmentationModelAccurate.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Image segmentation model to detect pets.
@available(iOS 11.0, *)
@objc(FritzVisionPetSegmentationModelAccurate)
public final class FritzVisionPetSegmentationModelAccurate: FritzVisionPetSegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "00957df90a544c15800e706d1ef74105",
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
    completionHandler: @escaping (FritzVisionPetSegmentationModelAccurate?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }

}
