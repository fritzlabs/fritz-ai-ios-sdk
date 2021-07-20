//
//  FritzVisionImageFilter.swift
//  FritzVision
//
//  Created by Steven Yeung on 10/29/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
public protocol FritzVisionImageFilter {

  typealias FritzVisionFilterResult = Result<FritzVisionImage, Error>

  /// How predictors are chosen by the filter.
  var compositionMode: FilterCompositionMode { get }

  /// Processes the image with a prediction.
  ///
  /// - Parameters:
  ///   - image: the image to process
  /// - Returns: the result of the prediction
  func process(_ image: FritzVisionImage) -> FritzVisionFilterResult
}

/// Specifies how a filter chooses a predictor.
public enum FilterCompositionMode {

  /// Use the previous image as a predictor.
  /// The output image will be the result of the filter.
  case compoundWithPreviousOutput

  /// Use the original image as a predictor.
  /// The output image will be the result of the filter overlayed on top of the input image.
  case overlayOnOriginalImage
}

@available(iOS 11.0, *)
extension CIImagePipeline {

  /// Applies a filter on the pipeline image.
  ///
  /// - Parameters:
  ///   - filter: the filter to apply
  public func compound(_ filter: FritzVisionImageFilter) throws {
    let fritzImage = FritzVisionImage(ciImage: image)
    let fritzResult = filter.process(fritzImage)
    switch fritzResult {
    case .success(let result):
      guard let outputImage = result.ciImage else {
        throw FritzVisionImageError.invalidCIImage
      }
      image = outputImage
    case .failure(let error):
      throw error
    }
  }

  /// Applies a filter on another image and overlays the result on the pipeline image.
  ///
  /// - Parameters:
  ///   - filter: the filter to apply
  ///   - base: the image to apply the filter on
  public func overlay(_ filter: FritzVisionImageFilter, using base: CIImage) throws {
    let fritzImage = FritzVisionImage(ciImage: base)
    let fritzResult = filter.process(fritzImage)
    switch fritzResult {
    case .success(let result):
      guard let outputImage = result.ciImage else {
        throw FritzVisionImageError.invalidCIImage
      }
      image = outputImage.composited(over: image)
    case .failure(let error):
      throw error
    }
  }
}
