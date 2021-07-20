import CoreGraphics

@objc(FritzVisionCropAndScale)
public enum FritzVisionCropAndScale: Int {
  case centerCrop = 1
  case scaleFill = 2
  case scaleFit = 3

  public var visionOption: VNImageCropAndScaleOption {
    switch self {
    case .centerCrop: return VNImageCropAndScaleOption.centerCrop
    case .scaleFill: return VNImageCropAndScaleOption.scaleFill
    case .scaleFit: return VNImageCropAndScaleOption.scaleFit
    }
  }

  public static func getCenterCropRect(forImageToScaleSize size: CGSize) -> CGRect {
    if size.height == size.width {
      return CGRect(origin: .zero, size: size)
    }

    if size.height > size.width {
      // tall skinny image, cutting off top and bottom
      let heightDifference = size.height - size.width
      let targetSize = CGSize(width: size.width, height: size.width)
      let yStart = heightDifference / 2
      let origin = CGPoint(x: 0.0, y: yStart)
      return CGRect(origin: origin, size: targetSize)
    }

    // Wide fat image, cutting off left and right sides
    let widthDifference = size.width - size.height
    let targetSize = CGSize(width: size.height, height: size.height)
    let xStart = widthDifference / 2
    let origin = CGPoint(x: xStart, y: 0.0)
    return CGRect(origin: origin, size: targetSize)
  }

}


/// An image or image buffer used in vision detection.
@objc(FritzVisionImage)
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class FritzVisionImage: NSObject {

  /// Shared CIContext
  @objc
  public static let sharedContext = CIContext(options: [.useSoftwareRenderer: false])

  /// CVPixelBuffer of image.
  public let imageBuffer: CVPixelBuffer?

  public let sampleBuffer: CMSampleBuffer?
  public let image: UIImage?

  public var metadata: FritzVisionImageMetadata?

  @objc(initWithBuffer:)
  public init(buffer: CMSampleBuffer) {
    self.image = nil
    self.sampleBuffer = buffer
    self.imageBuffer = nil
  }

  @objc(initWithImageBuffer:)
  public init(imageBuffer: CVPixelBuffer) {
    self.image = nil
    self.sampleBuffer = nil
    self.imageBuffer = imageBuffer
  }

  @objc(initWithCIImage:)
  convenience public init(ciImage: CIImage) {
    self.init(image: UIImage(ciImage: ciImage))
  }

  @objc(initWithImage:)
  public init(image: UIImage) {
    self.image = image
    self.sampleBuffer = nil
    self.imageBuffer = nil
  }

  @objc(initWithImage:orientation:)
  public init(image: UIImage, orientation: CGImagePropertyOrientation) {
    self.image = image
    self.sampleBuffer = nil
    self.imageBuffer = nil
    let metadata = FritzVisionImageMetadata()
    metadata.orientation = FritzImageOrientation(UIImage.Orientation(orientation))
    self.metadata = metadata
  }

  @objc(initWithImageBuffer:orientation:)
  public init(imageBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) {
    self.image = nil
    self.sampleBuffer = nil
    self.imageBuffer = imageBuffer
    let metadata = FritzVisionImageMetadata()
    metadata.orientation = FritzImageOrientation(UIImage.Orientation(orientation))
    self.metadata = metadata
  }

  @objc(initWithSampleBuffer:connection:)
  public init(sampleBuffer: CMSampleBuffer, connection: AVCaptureConnection) {
    self.image = nil
    self.sampleBuffer = sampleBuffer
    self.imageBuffer = nil
    let metadata = FritzVisionImageMetadata()
    metadata.orientation = FritzImageOrientation(from: connection)
    self.metadata = metadata
  }

  @objc func debugQuickLookObject() -> Any? {
    guard let image = self.rotated() else { return nil }
    return image
  }

  public func buildImageRequestHandler() -> VNImageRequestHandler? {
    if let image = image {
      if let cgImage = image.cgImage {
        if let imageMetadata = metadata {
          return VNImageRequestHandler(
            cgImage: cgImage,
            orientation: imageMetadata.cgOrientation,
            options: [:]
          )
        } else {
          return VNImageRequestHandler(cgImage: cgImage, options: [:])
        }
      } else if let ciImage = image.ciImage {
        if let imageMetadata = metadata {
          return VNImageRequestHandler(
            ciImage: ciImage,
            orientation: imageMetadata.cgOrientation,
            options: [:]
          )
        } else {
          return VNImageRequestHandler(ciImage: ciImage, options: [:])
        }
      }
    } else {
      let pixelBuffer: CVPixelBuffer
      var requestOptions: [VNImageOption: Any] = [:]
      if let sampleBuffer = sampleBuffer {
        guard let samplePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
          return nil
        }
        pixelBuffer = samplePixelBuffer
        if let cameraIntrinsicData = CMGetAttachment(
          sampleBuffer,
          key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix,
          attachmentModeOut: nil
        ) {
          requestOptions = [.cameraIntrinsics: cameraIntrinsicData]
        }
      } else {
        guard let imageBuffer = imageBuffer else {
          return nil
        }

        pixelBuffer = imageBuffer
      }
      if let imageMetadata = metadata {
        return VNImageRequestHandler(
          cvPixelBuffer: pixelBuffer,
          orientation: imageMetadata.cgOrientation,
          options: requestOptions
        )
      } else {
        return VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: requestOptions)
      }
    }
    return nil
  }
}

// MARK: - Image Size Computed Properties
@available(iOS 11.0, *)
extension FritzVisionImage {

  /// Dimensions of FritzVisionImage, after rotation
  @objc
  public var size: CGSize {
    let size = originalSize
    guard let metadata = metadata else { return size }

    switch metadata.orientation {
    case .up, .upMirrored, .down, .downMirrored: return size
    case .left, .leftMirrored, .right, .rightMirrored:
      return CGSize(width: size.height, height: size.width)
    }
  }

  /// Dimensions of input image without rotation.
  public var originalSize: CGSize {
    var size: CGSize!
    if let image = image {
      size = image.size
    } else if let imageBuffer = imageBuffer {
      let width = CVPixelBufferGetWidth(imageBuffer)
      let height = CVPixelBufferGetHeight(imageBuffer)
      size = CGSize(width: width, height: height)
    } else if let sampleBuffer = sampleBuffer,
      let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
    {
      let width = CVPixelBufferGetWidth(imageBuffer)
      let height = CVPixelBufferGetHeight(imageBuffer)
      size = CGSize(width: width, height: height)
    }
    return size
  }
}

// MARK: - Image Type Conversion
@available(iOS 11.0, *)
extension FritzVisionImage {

  public var ciImage: CIImage? {
    if let cgImage = image?.cgImage {
      return CIImage(cgImage: cgImage)
    } else if let ciImage = image?.ciImage {
      return ciImage
    } else {
      guard let buffer = toPixelBuffer() else { return nil }
      return CIImage(cvPixelBuffer: buffer)
    }
  }

  func toImage(_ image: CIImage, with providedContext: CIContext? = nil) -> UIImage? {
    let context = providedContext ?? FritzVisionImage.sharedContext
    guard let cgImage = context.createCGImage(image, from: image.extent) else {
      return nil
    }
    return UIImage(ciImage: CIImage(cgImage: cgImage))
  }

  @objc(toImage)
  public func toImage() -> UIImage? {
    if let imageBuffer = imageBuffer {
      return UIImage(ciImage: CIImage(cvPixelBuffer: imageBuffer))
    } else if let uiImage = image {
      return uiImage
    } else if let sampleBuffer = sampleBuffer {
      if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
        return UIImage(ciImage: CIImage(cvPixelBuffer: imageBuffer))
      }
    }
    return nil
  }

  @objc(toPixelBuffer)
  public func toPixelBuffer() -> CVPixelBuffer? {
    // Converting all types of FritzVisionImage initialization options to a CVPixelBuffer to
    // make it easy to operate on those values.
    if let imageBuffer = imageBuffer {
      return imageBuffer
    } else if let uiImage = image {
      let imageSize = uiImage.size
      return uiImage.pixelBuffer(width: Int(imageSize.width), height: (Int(imageSize.height)))
    } else if let sampleBuffer = sampleBuffer {
      return CMSampleBufferGetImageBuffer(sampleBuffer)
    }

    return nil
  }
}

//
@available(iOS 11.0, *)
extension FritzVisionImage {

  /// Prepare image for model input.  Resizes, crops, and rotates image.
  /// - Parameter size: Size to scale image
  /// - Parameter scaleCropOption: Scale crop option to use.
  public func prepare(
    size: CGSize,
    scaleCropOption: FritzVisionCropAndScale = .scaleFit
  ) -> CVPixelBuffer? {
    guard let image = ciImage else { return nil }
    let orientation: CGImagePropertyOrientation = metadata?.cgOrientation ?? .up
    let pipeline = CIImagePipeline(image)
    pipeline.orient(orientation)

    if scaleCropOption == .centerCrop {
      pipeline.centerCrop()
    }

    pipeline.resize(size)
    return pipeline.render()
  }

  @available(*, deprecated, renamed: "rotated()")
  @objc(rotate)
  public func rotate() -> CVPixelBuffer? {
    guard let image = ciImage else { return nil }
    let orientation: CGImagePropertyOrientation = metadata?.cgOrientation ?? .up
    let pipeline = CIImagePipeline(image)
    pipeline.orient(orientation)
    return pipeline.render()
  }

  /// Returns image applying rotation from `metatadata`.
  @objc(rotated)
  public func rotated() -> UIImage? {
    guard let image = ciImage else { return nil }
    let orientation: CGImagePropertyOrientation = metadata?.cgOrientation ?? .up
    let pipeline = CIImagePipeline(image)
    pipeline.orient(orientation)
    return UIImage(ciImage: pipeline.image)
  }

  /// Returns image applying rotation from `metatadata`.
  @objc(resizedToSize:)
  public func resized(to size: CGSize) -> UIImage? {
    guard let image = ciImage else { return nil }
    let pipeline = CIImagePipeline(image)
    pipeline.resize(size)
    return UIImage(ciImage: pipeline.image)
  }
}

public enum FritzVisionImageError: Error {
  case invalidCIImage
  case invalidUIImage
  case invalidCVPixelBuffer

  public func message() -> String {
    switch self {
    case .invalidCIImage:
      return """
        Could not create CIImage.
        Please ensure that you are using a valid UIImage or CVPixelBuffer.
        """
    case .invalidUIImage:
      return """
        Could not create UIImage.
        Please ensure that you are using a valid CMSampleBuffer or CVPixelBuffer.
        """
    case .invalidCVPixelBuffer:
      return """
        Could not create CVPixelBuffer.
        Please ensure that you are using a valid UIImage or CMSampleBuffer.
        """
    }
  }
}


@available(iOS 11.0, *)
extension FritzVisionImage {

  /// Resizes image to be within max dimension length.
  /// - Parameter length: Maximum length of largest size of image.
  public func resized(withMaxDimensionLessThan length: CGFloat) -> FritzVisionImage? {

    if originalSize.height <= length && originalSize.width <= length {
      return self
    }
    let aspectRatio = originalSize.width / originalSize.height
    var widthSize = length * aspectRatio
    var heightSize = length * 1 / aspectRatio

    if heightSize > length {
      heightSize = length
      widthSize = length * aspectRatio
    } else if widthSize > length {
      widthSize = length
      heightSize = length * 1 / aspectRatio
    }
    guard let uiImage = resized(to: CGSize(width: widthSize, height: heightSize)) else { return nil }
    let image = FritzVisionImage(image: uiImage)
    image.metadata = metadata
    return image
  }
}

