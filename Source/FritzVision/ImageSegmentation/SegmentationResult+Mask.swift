//
//  SegmentationResult+Mask.swift
//  Fritz
//
//  Created by Eric Hsiao on 7/23/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

extension UIImage {

  /// Create a new image from the source and alpha mask.
  ///
  /// - Parameters:
  ///   - source: the source image
  ///   - mask: the alpha mask
  ///   - context: the CIContext
  ///
  /// - Returns: the masked section from the source.
  public static func masked(
    _ source: UIImage,
    withAlphaMask mask: UIImage,
    using context: CIContext
  ) -> UIImage? {
    guard let imageCG = source.cgImage, let maskCG = mask.cgImage else { return nil }
    let imageCI = CIImage(cgImage: imageCG)
    let maskCI = CIImage(cgImage: maskCG)

    let empty = CIImage.empty()

    guard let filter = CIFilter(name: "CIBlendWithAlphaMask") else { return nil }
    filter.setValue(imageCI, forKey: "inputImage")
    filter.setValue(maskCI, forKey: "inputMaskImage")
    filter.setValue(empty, forKey: "inputBackgroundImage")

    guard let maskedImage = context.createCGImage(filter.outputImage!, from: maskCI.extent) else {
      return nil
    }

    return UIImage(ciImage: CIImage(cgImage: maskedImage))
  }
}

@available(iOS 11.0, *)
extension CIImagePipeline {

  /// Mask image using a single class alpha RGBA mask.
  ///
  /// - Parameters:
  ///   - alphaMask: RGBA alpha mask
  ///   - segmentationRegion: Region of image to remove.  `background` removes all areas
  ///       where alpha value of mask is 0.
  public func mask(
    with alphaMask: UIImage,
    removing segmentationRegion: SegmentationRegion = .background
  ) {
    var optionalMask: CIImage?
    if let ciAlphaMask = alphaMask.ciImage {
      optionalMask = ciAlphaMask
    } else if let cgAlphaMask = alphaMask.cgImage {
      optionalMask = CIImage(cgImage: cgAlphaMask)
    }

    guard var ciAlphaMask = optionalMask else {
      return
    }

    ciAlphaMask
      = self.resized(
        ciAlphaMask,
        to: image.extent.size,
        usingSamplingMethod: resizeSamplingMethod
      )

    let empty = CIImage.empty()

    guard let filter = CIFilter(name: "CIBlendWithAlphaMask") else { return }
    filter.setValue(ciAlphaMask, forKey: "inputMaskImage")
    switch segmentationRegion {
    case .foreground:
      filter.setValue(empty, forKey: "inputImage")
      filter.setValue(image, forKey: "inputBackgroundImage")
    case .background:
      filter.setValue(image, forKey: "inputImage")
      filter.setValue(empty, forKey: "inputBackgroundImage")
    }
    guard let image = filter.outputImage else { return }
    self.image = image
  }

}

@objc(FritzSegmentationRegion)
public enum SegmentationRegion: Int {
  /// Foreground is the region of the image where the alpha value of a mask is greater than 0.
  case foreground

  /// Background is the region of the image where the alpha value of a mask is 0.
  case background
}

@available(iOS 11.0, *)
extension FritzVisionImage {

  /// Uses an alpha mask to cutout maked regions, specifying with area of mask to keep.
  ///
  /// - Parameters:
  ///   - alphaMask: Alpha Mask with a single class.
  ///   - segmentationRegion: Region of alpha mask to remove.
  ///   - samplingMethod: Resizing sampling method to use.
  ///   - context: Optional Core Image context to use.  Defaults to
  ///       `FritzVisionImage.sharedContext`
  /// - Returns: Masked image.
  @objc(maskWithImage:removingPixelsIn:samplingMethod:context:)
  public func masked(
    with alphaMask: UIImage,
    removing segmentationRegion: SegmentationRegion = .background,
    resizeSamplingMethod samplingMethod: CIImagePipeline.ResizeSamplingMethod = .lanczos,
    using context: CIContext? = nil
  ) -> UIImage? {
    guard let ciImage = ciImage else { return nil }

    let pipeline = CIImagePipeline(ciImage, context: context)
    pipeline.resizeSamplingMethod = samplingMethod
    pipeline.orient(metadata?.cgOrientation ?? .up)
    pipeline.mask(with: alphaMask, removing: segmentationRegion)
    return UIImage(ciImage: pipeline.image)
  }
}
