//
//  HairSegmentationFast.swift
//  FritzVision
//
//  Created by Christopher Kelly on 9/20/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
@objc(FritzVisionHairSegmentationModelFast)
public final class FritzVisionHairSegmentationModelFast: FritzVisionHairSegmentationPredictor,
  DownloadableModel
{

  @objc public static let modelConfig = FritzModelConfiguration(
    identifier: "aa7e346857a04cff993e8f2d225a96c8",
    version: 7,
    pinnedVersion: 7
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
    completionHandler: @escaping (FritzVisionHairSegmentationModelFast?, Error?) -> Void
  ) {
    _fetchModel(completionHandler: completionHandler)
  }
}
