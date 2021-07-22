//
//  BoundingBox.swift
//  FritzVision
//
//  Created by Christopher Kelly on 10/1/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// BoundingBox Contains coordinates to draw bounding boxes on images as predicted directly by the model.  However, because of cropping or resizing done to accomadate model size constraints, the default values may not map to coordinates in your view.  Use the toCGRect functions to convert bounding box coordinates to fit the image.
@objc(BoundingBox)
public class BoundingBox: NSObject {
  public let yMin: Double
  public let xMin: Double
  public let yMax: Double
  public let xMax: Double

  @objc(initWithYMin:xMin:yMax:xMax:)
  public init(yMin: Double, xMin: Double, yMax: Double, xMax: Double) {
    self.yMin = yMin
    self.xMin = xMin
    self.yMax = yMax
    self.xMax = xMax
  }

  public init(fromAnchor anchor: Anchor) {
    self.yMin = anchor.yMin
    self.yMax = anchor.yMax
    self.xMin = anchor.xMin
    self.xMax = anchor.xMax
  }

  public init(from rect: CGRect) {
    self.yMin = Double(rect.minY)
    self.xMin = Double(rect.minX)
    self.yMax = Double(rect.maxY)
    self.xMax = Double(rect.maxX)
  }

  public var cgRect: CGRect {
    return CGRect(x: xMin, y: yMin, width: xMax - xMin, height: yMax - yMin)
  }

  // Transposes to image height and width
  @objc(imgHeight:imgWidth:)
  public func toCGRect(imgHeight: Double, imgWidth: Double) -> CGRect {
    let height = imgHeight * (yMax - yMin)
    let width = imgWidth * (xMax - xMin)

    return CGRect(x: imgWidth * xMin, y: imgHeight * yMin, width: width, height: height)
  }

  // Transposes coordinates to image with given h/w and offset.
  @objc(imgHeight:imgWidth:xOffset:yOffset:)
  public func toCGRect(imgHeight: Double, imgWidth: Double, xOffset: Double, yOffset: Double)
    -> CGRect
  {
    let height = imgHeight * (yMax - yMin)
    let width = imgWidth * (xMax - xMin)

    return CGRect(
      x: imgWidth * xMin + xOffset,
      y: imgHeight * yMin + yOffset,
      width: width,
      height: height
    )
  }

  /// Scale object result by size.
  ///
  /// - Parameter size: Size to scale result from
  /// - Returns: CGRect of scaled bounding box.
  public func scaledBy(_ size: CGSize) -> CGRect {
    let imgWidth = Double(size.width)
    let imgHeight = Double(size.height)

    let height = imgHeight * (yMax - yMin)
    let width = imgWidth * (xMax - xMin)

    return CGRect(x: imgWidth * xMin, y: imgHeight * yMin, width: width, height: height)
  }
}
