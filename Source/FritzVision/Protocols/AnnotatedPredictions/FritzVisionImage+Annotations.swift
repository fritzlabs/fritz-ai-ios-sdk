//
//  FritzVisionImage+Annotations.swift
//  FritzVision
//
//  Created by Christopher Kelly on 11/13/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
extension FritzVisionImage: Base64StringEncodable {

  /// Sets the compression quality of jpeg output
  private var jpegCompressionQuality: CGFloat { 0.7 }

  public func encode() throws -> String {
    guard let rotated = rotated() else {
      throw FritzVisionError.errorProcessingImage
    }

    guard let compressed = rotated.jpegData(compressionQuality: jpegCompressionQuality) else {
      throw FritzVisionError.imageNotEncodable
    }

    return compressed.base64EncodedString()
  }

  public func encodedImageDimensions() throws -> CGSize {
    return size;
  }

  // TODO: This is supposed to be sent to the server so that it
  // knows how to decode the data.
  public var encodedFormat: EncodedFormat { .image }
}
