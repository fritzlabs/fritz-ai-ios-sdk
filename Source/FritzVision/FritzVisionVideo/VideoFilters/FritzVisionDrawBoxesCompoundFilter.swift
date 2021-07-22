//
//  FritzVisionDrawBoxesCompoundFilter.swift
//  AllFritzTests
//
//  Created by Steven Yeung on 10/29/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import UIKit

/// Draws boxes surrounding detected objects.
@available(iOS 12.0, *)
public class FritzVisionDrawBoxesCompoundFilter: FritzVisionImageFilter {

  public let compositionMode = FilterCompositionMode.compoundWithPreviousOutput
  public let model: FritzVisionObjectPredictor
  public let options: FritzVisionObjectModelOptions
  private let baseLayer = CALayer()
  private let numBoxes = 100
  private var boundingBoxes: [BoundingBoxOutline] = []

  public init(
    model: FritzVisionObjectPredictor,
    options: FritzVisionObjectModelOptions = .init()
  ) {
    self.model = model
    self.options = options
    setupBoxes()
  }

  public func process(_ image: FritzVisionImage) -> FritzVisionFilterResult {
    baseLayer.removeAllAnimations()
    do {
      let result = try model.predict(image, options: options)
      return try .success(drawBoxes(on: image, predictions: result))
    } catch let error {
      return .failure(error)
    }
  }

  private func setupBoxes() {
    // Create shape layers for the bounding boxes.
    for _ in 0..<numBoxes {
      let box = BoundingBoxOutline()
      self.boundingBoxes.append(box)
    }
  }

  private func drawBoxes(
    on image: FritzVisionImage,
    predictions: [FritzVisionObject]
  ) throws -> FritzVisionImage {
    guard let baseImage = image.ciImage else {
      throw FritzVisionImageError.invalidCIImage
    }
    let imageSize = image.size
    let imageFrame = CGRect(origin: .zero, size: imageSize)
    let cgContext = CIContext(options: nil)
    let convertedImage = cgContext.createCGImage(baseImage, from: imageFrame)

    baseLayer.frame = imageFrame
    baseLayer.contents = convertedImage

    for (index, prediction) in predictions.enumerated() {
      let textLabel = String(format: "%.2f - %@", prediction.confidence, prediction.label)
      let height = Double(imageSize.height)
      let width = Double(imageSize.width)

      // Scale the box with respect to the image size
      let box = prediction.boundingBox
      let rect = box.toCGRect(imgHeight: height, imgWidth: width)
      let currentOutline = self.boundingBoxes[index]
      currentOutline.addToLayer(baseLayer)
      self.boundingBoxes[index].show(
        frame: rect,
        label: textLabel,
        color: UIColor.red,
        textColor: UIColor.black
      )
    }

    for index in predictions.count..<self.numBoxes {
      self.boundingBoxes[index].hide()
    }

    // Convert CALayer to an UIImage
    UIGraphicsBeginImageContextWithOptions(imageSize, false, 1)
    guard let context = UIGraphicsGetCurrentContext() else {
      throw FritzVisionVideoError.invalidPrediction
    }
    baseLayer.render(in: context)
    let outputImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    // Force unwrap since the layer will always have at least the original image
    return FritzVisionImage(image: outputImage!)
  }
}
