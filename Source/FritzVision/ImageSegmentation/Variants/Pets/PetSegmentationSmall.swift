//
//  FritzVisionPetSegmentationModelSmall.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Image segmentation model to detect pets.
@available(iOS 12.0, *)
@objc(FritzVisionPetSegmentationModelSmall)
public final class FritzVisionPetSegmentationModelSmall: FritzVisionPetSegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "e82138e795814281944eddc1c65c6ded",
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
    completionHandler: @escaping (FritzVisionPetSegmentationModelSmall?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }

}
