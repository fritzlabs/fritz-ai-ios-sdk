//
//  SegmentationResult+GenerateMasks.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/23/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

extension CGRect {

  func scale(_ scale: CGFloat) -> CGRect {
    let newPoint = CGPoint(x: origin.x * scale, y: origin.y * scale)
    let newSize = CGSize(width: size.width * scale, height: size.height * scale)
    return CGRect(origin: newPoint, size: newSize)
  }
}

@available(iOS 11.0, *)
extension UIImage {

  func resized(
    to size: CGSize,
    usingSamplingMethod samplingMethod: CIImagePipeline.ResizeSamplingMethod = .affine
  ) -> UIImage? {
    guard
      let pipeline: CIImagePipeline = {
        if let ciImage = ciImage {
          return CIImagePipeline(ciImage)
        } else if let cgImage = cgImage {
          return CIImagePipeline(CIImage(cgImage: cgImage))
        }
        return nil
      }()
    else { return nil }
    pipeline.resizeSamplingMethod = samplingMethod
    pipeline.resize(size)
    return UIImage(ciImage: pipeline.image)
  }
}

extension UIImage {

  @available(iOS 11.0, *)
  func placeMaskInCenterCroppedScale(resize: Bool, originalSize: CGSize) -> UIImage? {
    if resize == true {
      let outputCropRect = FritzVisionCropAndScale.getCenterCropRect(
        forImageToScaleSize: originalSize
      )

      return self.resized(to: originalSize, atRect: outputCropRect)
    }

    // Here we are not resizing the mask, but we still need to place it
    // with appropriate padding
    let outputCropRect = FritzVisionCropAndScale.getCenterCropRect(
      forImageToScaleSize: originalSize
    )

    if originalSize.height > originalSize.width {
      // Tall image: min size is width, used to compute ratio
      let originalAspectRatio = originalSize.height / originalSize.width
      let rescaleRatio = size.width / originalSize.width
      let newContainerSize = CGSize(width: size.width, height: size.height * originalAspectRatio)
      return self.resized(to: newContainerSize, atRect: outputCropRect.scale(rescaleRatio))
    }

    // Wide image: min size is height, used to compute ratio
    let originalAspectRatio = originalSize.width / originalSize.height
    let rescaleRatio = size.height / originalSize.height
    let newContainerSize = CGSize(width: size.width * originalAspectRatio, height: size.height)

    return self.resized(to: newContainerSize, atRect: outputCropRect.scale(rescaleRatio))
  }
}

extension UIImage {

  @available(iOS 11.0, *)
  func blurMask(blurRadius: CGFloat) -> UIImage? {
    guard
      let pipeline: CIImagePipeline = {
        if let ciImage = ciImage {
          return CIImagePipeline(ciImage)
        } else if let cgImage = cgImage {
          return CIImagePipeline(CIImage(cgImage: cgImage))
        }
        return nil
      }()
    else { return nil }
    pipeline.blur(blurRadius: blurRadius)
    return UIImage(ciImage: pipeline.image)
  }
}

// MARK: - Segmentation Masks

@available(iOS 11.0, *)
public class FritzVisionSegmentationMaskOptions: NSObject {

  /// Scores output from model greater than this value will be set as 1.
  /// Lowering this value will make the mask more intense for lower confidence values.
  public var clippingScoresAbove: Double = 0.7

  /// Values lower than this value will not appear in the mask.
  public var zeroingScoresBelow: Double = 0.3

  /// Alpha value of the mask.
  public var maxAlpha: UInt8 = 255

  /// Color of the mask.
  public var maskColor: UIColor = .blue

  /// The radius to blur the edges of the mask.
  public var blurRadius: CGFloat = 0
}

@available(iOS 11.0, *)
extension FritzVisionSegmentationResult {

  func buildMask(
    fromArrayOfClasses array: [Int32],
    alpha: UInt8,
    resize: Bool
  ) -> UIImage? {
    let destBytes = convertMultiClassValuesToColor(for: array, alpha: alpha)

    guard
      let image = UIImage.fromByteArrayRGBA(
        destBytes,
        width: width,
        height: height,
        scale: 0,
        orientation: .up
      )
    else { return nil }

    if cropOption == .centerCrop {
      return image.placeMaskInCenterCroppedScale(
        resize: resize,
        originalSize: imageSize
      )?.imageBackedByCIImage
    }

    if resize == false {
      return image.imageBackedByCIImage
    }

    return image.resized(to: imageSize)?.imageBackedByCIImage
  }

  func buildMask(
    fromArrayOfClasses array: [Int32],
    alpha: UInt8,
    resize: Bool,
    blurRadius: CGFloat
  ) -> UIImage? {
    guard let image = self.buildMask(fromArrayOfClasses: array, alpha: alpha, resize: resize) else {
      return nil
    }

    if blurRadius > 0 {
      return image.blurMask(blurRadius: blurRadius)
    }

    return image
  }

  func buildImageFromSingleClassValues(
    for reducedArray: [Float],
    color: rgbaValue,
    alpha: UInt8,
    resize: Bool
  ) -> UIImage? {
    let destBytes = convertSingleClassConfidenceScoresToColor(
      for: reducedArray,
      color: color,
      alpha: alpha
    )

    guard
      let image = UIImage.fromByteArrayRGBA(
        destBytes,
        width: width,
        height: height,
        scale: 0,
        orientation: .up
      )
    else { return nil }

    if cropOption == .centerCrop {
      return image.placeMaskInCenterCroppedScale(
        resize: resize,
        originalSize: imageSize
      )?.imageBackedByCIImage
    }

    if resize == false {
      return image.imageBackedByCIImage
    }

    return image.resized(to: imageSize)?.imageBackedByCIImage
  }

  func buildImageFromSingleClassValues(
    for reducedArray: [Float],
    color: rgbaValue,
    alpha: UInt8,
    resize: Bool,
    blurRadius: CGFloat
  ) -> UIImage? {
    guard
      let image = buildImageFromSingleClassValues(
        for: reducedArray,
        color: color,
        alpha: alpha,
        resize: resize
      )
    else { return nil }

    if blurRadius > 0 {
      return image.blurMask(blurRadius: blurRadius)?.imageBackedByCIImage
    }

    return image.imageBackedByCIImage
  }

  /// Generate UIImage mask from most likely class at each pixel.
  ///
  /// The generated image size will fit the original image passed into prediction, applying rotation.
  /// If the image was center cropped, will return an image that covers the cropped image.
  ///
  /// - Parameters:
  ///   - minScore: Minimum threshold value needed to count. By default zero.
  ///       You can set this property to filter out classes that may be the most likely but still
  ///       have a lower probability.
  ///   - maxAlpha: Alpha value of the color (0-255) for detected classes. By default completely opaque.
  ///   - resize: If true (default) mask will be scaled to the size of the input image.
  ///   - blurRadius: The radius to blur the edges of the mask.
  ///
  /// - Returns: Image
  @objc(buildMultiClassMaskWithMinAcceptedScore:maxAlpha:resize:blurRadius:)
  public func buildMultiClassMask(
    withMinimumAcceptedScore minScore: Double = 0.0,
    maxAlpha: UInt8 = 255,
    resize: Bool = true,
    blurRadius: CGFloat = 0
  ) -> UIImage? {
    let array = getArrayOfMostLikelyClasses(withMinimumConfidenceScore: minScore)
    return buildMask(
      fromArrayOfClasses: array,
      alpha: maxAlpha,
      resize: resize,
      blurRadius: blurRadius
    )
  }

  /// Generate UIImage mask for given class.
  ///
  /// The generated image size will fit the original image passed into prediction, applying rotation.
  /// If the image was center cropped, will return an image that covers the cropped image.
  ///
  /// - Parameters:
  ///   - segmentClass: Class for the mask.
  ///   - clippingThreshold: All confidence scores above this value will be clipped to 1.
  ///       Range [0.0-1.0].
  ///   - zeroingThreshold: All confidence scores below this value will be set to 0.
  ///       Range [0.0-1.0].
  ///   - maxAlpha: Maximum alpha value of mask. Confidence scores will be multiplied by this value
  ///       after clipping and zeroing.
  ///   - resize: If true, resizes mask to input image size.
  ///   - color: The color of mask.
  ///   - blurRadius: The radius to blur the edges of the mask.
  ///
  /// - Returns: Mask for class.
  @objc(
    buildSingleClassMask:
    clippingScoresAbove:
    zeroingScoresBelow:
    maxAlpha:
    resize:
    color:
    blurRadius:
  )
  public func buildSingleClassMask(
    forClass segmentClass: ModelSegmentationClass,
    clippingScoresAbove clippingThreshold: Double = 0.5,
    zeroingScoresBelow zeroingThreshold: Double = 0.5,
    maxAlpha: UInt8 = 255,
    resize: Bool = true,
    color: UIColor? = nil,
    blurRadius: CGFloat = 0
  ) -> UIImage? {

    var newColor = segmentClass.color
    if let color = color, let rgbaValue = color.rgbaValue {
      newColor = rgbaValue
    }
    let array = getArrayOfConfidenceScores(
      forClass: segmentClass,
      clippingScoresAbove: clippingThreshold,
      zeroingScoresBelow: zeroingThreshold
    )

    return buildImageFromSingleClassValues(
      for: array,
      color: newColor,
      alpha: maxAlpha,
      resize: resize,
      blurRadius: blurRadius
    )
  }

  /// Generate UIImage mask for given class.
  ///
  /// The generated image size will fit the original image passed into prediction, applying rotation.
  /// If the image was center cropped, will return an image that covers the cropped image.
  ///
  /// - Parameters:
  ///   - segmentClass: Class for the mask.
  ///   - options: Options for the mask.
  ///   - resize: If true, resizes mask to input image size.
  ///
  /// - Returns: Mask for class.
  @objc(
    buildSingleClassMask:
    options:
    resize:
  )
  public func buildSingleClassMask(
    forClass segmentClass: ModelSegmentationClass,
    options: FritzVisionSegmentationMaskOptions,
    resize: Bool = true
  ) -> UIImage? {

    return buildSingleClassMask(
      forClass: segmentClass,
      clippingScoresAbove: options.clippingScoresAbove,
      zeroingScoresBelow: options.zeroingScoresBelow,
      maxAlpha: options.maxAlpha,
      resize: resize,
      color: options.maskColor,
      blurRadius: options.blurRadius
    )
  }
}
