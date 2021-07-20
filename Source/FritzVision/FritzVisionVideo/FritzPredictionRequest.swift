//
//  FritzPredictionRequest.swift
//  FritzVision
//
//  Created by Steven Yeung on 10/25/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import AVFoundation
import Foundation

@available(iOS 11.0, *)
extension AVAsynchronousCIImageFilteringRequest {

  /// Converts the current frame to a FritzVisionImage.
  public var fritzImage: FritzVisionImage {
    return FritzVisionImage(ciImage: sourceImage)
  }
}

@available(iOS 11.0, *)
extension AVVideoComposition {

  /// Initializes by composing an AVAsynchronousCIImageFilteringRequest using the given filters.
  ///
  /// - Parameters:
  ///   - asset: the video content
  ///   - filters: the filters to apply on the video
  convenience init(asset: AVAsset, applyingFilters filters: [FritzVisionImageFilter]) {
    self.init(
      asset: asset,
      applyingCIFiltersWithHandler: { request in
        let sourceImage = request.sourceImage
        do {
          let pipeline = CIImagePipeline(sourceImage)
          for filter in filters {
            switch filter.compositionMode {
            case .compoundWithPreviousOutput:
              try pipeline.compound(filter)
            case .overlayOnOriginalImage:
              try pipeline.overlay(filter, using: sourceImage)
            }
          }
          request.finish(with: pipeline.image, context: pipeline.context)
        } catch let error {
          request.finish(with: error)
        }
    }
    )
  }
}
