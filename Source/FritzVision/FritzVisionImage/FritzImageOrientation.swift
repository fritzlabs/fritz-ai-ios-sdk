//
//  FritzImageOrientation.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/8/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Describes the orientation of the image. The orientations match the [CGImagePropertyOrientation](https://developer.apple.com/documentation/imageio/cgimagepropertyorientation) Enumeration from Apple. Refer to that documentation for clear descriptions of each case.
@available(iOS 11.0, *)
@objc
public enum FritzImageOrientation: Int32 {

  case up = 1
  case upMirrored
  case down
  case downMirrored
  case leftMirrored
  case right
  case rightMirrored
  case left

}

@available(iOS 11.0, *)
extension FritzImageOrientation {

  public init(_ uiOrientation: UIImage.Orientation) {
    switch uiOrientation {
    case .up: self = .up
    case .upMirrored: self = .upMirrored
    case .down: self = .down
    case .downMirrored: self = .downMirrored
    case .left: self = .left
    case .leftMirrored: self = .leftMirrored
    case .right: self = .right
    case .rightMirrored: self = .rightMirrored
    @unknown default:
      self = .up
    }
  }

  /// Initialize from AVCaptureConnection.  This chooses reasonable defaults from the orientation of the camera. Note that this will not take device orientation into account.
  ///
  /// - Parameter connection: AVCaptureConnection
  public init(from connection: AVCaptureConnection) {
    self = FritzImageOrientation.fromAVCaptureConnection(from: connection)
  }

  public static func fromAVCaptureConnection(from connection: AVCaptureConnection)
    -> FritzImageOrientation
  {
    switch FritzCore.orientationManager.orientation {
    case .faceUp, .unknown, .faceDown, .portrait, .portraitUpsideDown:
      switch connection.videoOrientation {
      case .portrait, .portraitUpsideDown:
        return .up
      case .landscapeLeft:
        return .left
      case .landscapeRight:
        return .right
      @unknown default:
        return .up
      }
    case .landscapeLeft:
      switch connection.videoOrientation {
      case .portrait:
        return .left
      case .portraitUpsideDown:
        return .right
      case .landscapeLeft:
        return .down
      case .landscapeRight:
        return .up
      @unknown default:
        return .up
      }
    case .landscapeRight:
      switch connection.videoOrientation {
      case .portrait:
        return .right
      case .portraitUpsideDown:
        return .left
      case .landscapeLeft:
        return .up
      case .landscapeRight:
        return .down
      @unknown default:
        return .up
      }
    @unknown default:
      return .up
    }
  }
}
