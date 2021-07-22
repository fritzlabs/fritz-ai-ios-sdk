//
//  FritzVision.swift
//  FritzVision
//
//  Created by Andrew Barba on 6/18/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import AVFoundation
import Foundation
import Vision

@available(iOS 11.0, *)
@objc(FritzVisionImageMetadata)
public class FritzVisionImageMetadata: NSObject {
  public override init() { super.init() }

  /// Orientation defaults to `FritzImageOrientation.right` which should work for rear facing cameras with a device orientation of Portrait.
  @objc public var orientation: FritzImageOrientation = .right

  @objc public var cgOrientation: CGImagePropertyOrientation {
    switch orientation {
    case .up:
      return CGImagePropertyOrientation.up
    case .upMirrored:
      return CGImagePropertyOrientation.upMirrored
    case .down:
      return CGImagePropertyOrientation.down
    case .downMirrored:
      return CGImagePropertyOrientation.downMirrored
    case .leftMirrored:
      return CGImagePropertyOrientation.leftMirrored
    case .right:
      return CGImagePropertyOrientation.right
    case .rightMirrored:
      return CGImagePropertyOrientation.rightMirrored
    case .left:
      return CGImagePropertyOrientation.left
    }
  }

}
