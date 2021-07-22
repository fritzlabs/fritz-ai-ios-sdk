//
//  CIImagePipeline.swift
//  FritzVision
//
//  Created by Christopher Kelly on 7/24/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import CoreImage
import Foundation

@available(iOS 11.0, *)
@objcMembers
/// Pipeline for appling image transformation functions to a CIImage.
public class CIImagePipeline: NSObject {

  /// Sampling method used to resize image.
  @objc(ResizeSamplingMethod)
  public enum ResizeSamplingMethod: Int {
    /// Lanczos Sampling method
    case lanczos

    /// Bicubic Sampling method.
    case bicubic

    /// Affine transformation resampling. This is the fastest method but results in more edge artifacts.
    case affine
  }

  /// Image context used to render CIImage pipeline
  let context: CIContext

  /// Current CIImage.
  public var image: CIImage

  /// Sampling method use when resizing images.  Defaults to `.affine`, which is the fastest but produces the most artifacts.
  public var resizeSamplingMethod: ResizeSamplingMethod = .affine

  fileprivate let logger = Logger(name: "CIImagePipeline")

  /// Create `CIImagePipeline`
  /// - Parameter image: Input CIImage
  /// - Parameter context: CIImage context. If not provided, uses FritzVisionImage shared context.
  public init(_ image: CIImage, context: CIContext? = nil) {
    self.image = image
    self.context = context ?? FritzVisionImage.sharedContext
  }

  /// Render current CIImage to pixelBuffer
  public func render() -> CVPixelBuffer? {
    guard let buffer = emptyPixelBuffer() else { return nil }
    context.render(image, to: buffer)
    return buffer
  }

  func emptyPixelBuffer() -> CVPixelBuffer? {
    var pixelBuffer: CVPixelBuffer?
    let height = Int(image.extent.height)
    let width = Int(image.extent.width)
    let attrs = [
      kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
      kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
    ]

    // TODO Change pixel format type to match input image possibly?

    CVPixelBufferCreate(
      kCFAllocatorDefault,
      width,
      height,
      kCVPixelFormatType_32ARGB,
      attrs as CFDictionary,
      &pixelBuffer
    )

    return pixelBuffer
  }
}

// MARK: - Image Processing

@available(iOS 11.0, *)
extension CIImagePipeline {

  /// Center Crop Image
  public func centerCrop() {
    let rect = FritzVisionCropAndScale.getCenterCropRect(forImageToScaleSize: image.extent.size)
    image = image.cropped(to: rect)
  }

  /// Orients image from given orientation to up orientation.
  ///
  /// - Parameter orientation: Orientation
  public func orient(_ orientation: CGImagePropertyOrientation) {
    if orientation == .up {
      return
    }
    image = image.oriented(orientation)
  }

  func resized(
    _ image: CIImage,
    to size: CGSize,
    usingSamplingMethod samplingMethod: ResizeSamplingMethod? = nil
  ) -> CIImage {
    let scaleX = size.width / image.extent.width
    let scaleY = size.height / image.extent.height
    let aspectRatio = scaleX / scaleY

    switch samplingMethod ?? resizeSamplingMethod {
    case .affine:
      let scaleTransform = CGAffineTransform.init(scaleX: CGFloat(scaleX), y: CGFloat(scaleY))
      return image.transformed(by: scaleTransform)
    case .lanczos:
      return image.applyingFilter(
        "CILanczosScaleTransform",
        parameters: [
          kCIInputImageKey: image,
          kCIInputAspectRatioKey: aspectRatio,
          kCIInputScaleKey: scaleY,
        ]
      )
    case .bicubic:
      return image.applyingFilter(
        "CIBicubicScaleTransform",
        parameters: [
          kCIInputImageKey: image,
          kCIInputAspectRatioKey: aspectRatio,
          kCIInputScaleKey: scaleY,
        ]
      )
    }
  }

  /// Resizes image.
  /// - Parameter size: Desired output size of image.
  public func resize(
    _ size: CGSize,
    usingSamplingMethod samplingMethod: ResizeSamplingMethod? = nil
  ) {
    image = resized(image, to: size, usingSamplingMethod: samplingMethod)
    // Occasionally if the input image is too large, there may be a slight mismatch
    // in the resulting size.  If the sizes don't match,
    if image.extent.size != size {
      logger.debug(
        "Sizes didn't match after resizing, trying again: \(image.extent.size) != \(size)"
      )
      image = resized(image, to: size, usingSamplingMethod: samplingMethod)
    }
  }

  /// Blends image with provided mask.
  ///
  /// - Parameter mask: Alpha matting mask to blend image with
  /// - Parameter kernel: Blend kernel used to blend mask with background image.
  /// - Parameter opacity: Opacity of mask [0.0 - 1.0] overlayed on source image.
  public func blend(
    with mask: UIImage,
    blendKernel kernel: CIBlendKernel = CIBlendKernel.softLight,
    opacity: CGFloat = 1.0
  ) {
    var maskImage: CIImage!
    if let cgImage = mask.cgImage {
      maskImage = CIImage(cgImage: cgImage)
    } else {
      maskImage = mask.ciImage!
    }
    maskImage = resized(maskImage, to: image.extent.size)

    if opacity != 1.0 {
      if let modifiedAlpha = changeOpacity(on: maskImage, to: opacity) {
        maskImage = modifiedAlpha
      }
    }
    guard let blended = kernel.apply(foreground: maskImage, background: image) else { return }
    image = blended
  }

  func changeOpacity(on image: CIImage, to opacity: CGFloat) -> CIImage? {

    // The CIColorMatrix filter, will contain the requested filter and control its opacity
    guard let overlayFilter: CIFilter = CIFilter(name: "CIColorMatrix") else { return nil }
    let overlayRgba: [CGFloat] = [0, 0, 0, opacity]
    let alphaVector: CIVector = CIVector(values: overlayRgba, count: 4)
    overlayFilter.setValue(image, forKey: kCIInputImageKey)
    overlayFilter.setValue(alphaVector, forKey: "inputAVector")
    return overlayFilter.outputImage
  }

  /// Blurs image.
  ///
  /// - Parameter blurRadius: Pixel radius of the blur kernel
  public func blur(blurRadius: CGFloat) {
    guard let filter = CIFilter(name: "CIBoxBlur") else { return }
    filter.setValue(image, forKey: kCIInputImageKey)
    filter.setValue(blurRadius, forKey: "inputRadius")
    guard let outputImage = filter.outputImage else { return }
    image = outputImage
  }
}
