//
//  HairSegmentationSmall.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 12.0, *)
@objc(FritzVisionHairSegmentationModelSmall)
public final class FritzVisionHairSegmentationModelSmall: FritzVisionHairSegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "22bfced28df740609c5111fdae21e4bc",
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
    completionHandler: @escaping (FritzVisionHairSegmentationModelSmall?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
