//
//  SegmentationResult+Blending.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/23/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

extension UIImage {

  /// Blend source and mask images using the specified blend mode.
  ///
  /// If the mask is smaller than the source image, the interpolationQuality
  /// is used when resizing the mask to fit the source image bounds.
  ///
  /// - Parameters:
  ///   - source: Background image
  ///   - mask: Mask to blend with background image
  ///   - blendMode: Blend mode used to blend images.
  ///   - interpolationQuality: Quality of interpolation when resizing image.
  ///   - opacity: Opacity of mask [0.0 - 1.0]
  ///
  /// - Returns: Blended image
  public static func blend(
    _ source: UIImage,
    with mask: UIImage,
    blendMode: CGBlendMode = .softLight,
    interpolationQuality: CGInterpolationQuality = .none,
    opacity: CGFloat = 1.0
  ) -> UIImage? {
    UIGraphicsBeginImageContext(source.size)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }

    let rect = CGRect(origin: CGPoint.zero, size: source.size)

    source.draw(in: rect)
    context.interpolationQuality = interpolationQuality

    // Draw in provided maskRect if it exists.
    mask.draw(in: rect, blendMode: blendMode, alpha: opacity)

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
}

@available(iOS 11.0, *)
extension FritzVisionImage {

  /// Blends mask with current image.
  ///
  /// Rotates source image to `up` orientation before blending.
  ///
  /// - Parameters:
  ///   - mask: Overlaying image
  ///   - blendKernel: Blend mode used to blend images.
  ///   - samplingMethod: Method used to sample images when resizing images.
  ///   - opacity: Opacity of mask [0.0 - 1.0] overlayed on source image.
  ///
  /// - Returns: Blended image
  @objc(blendWithMask:blendMode:samplingMethod:opacity:)
  public func blend(
    withMask mask: UIImage,
    blendKernel: CIBlendKernel = .softLight,
    resizeSamplingMethod samplingMethod: CIImagePipeline.ResizeSamplingMethod = .lanczos,
    opacity: CGFloat = 1.0
  ) -> UIImage? {
    guard let ciImage = ciImage else { return nil }
    let pipeline = CIImagePipeline(ciImage)
    pipeline.resizeSamplingMethod = samplingMethod
    pipeline.orient(metadata?.cgOrientation ?? .up)
    pipeline.blend(with: mask, blendKernel: blendKernel, opacity: opacity)
    return UIImage(ciImage: pipeline.image)
  }

}
