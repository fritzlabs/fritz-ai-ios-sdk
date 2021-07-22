//
//  Base64Encodable.swift
//  FritzVision
//
//  Created by Christopher Kelly on 11/13/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation


public enum EncodedFormat: String, RawRepresentable {
  case image = "image"
}

/// A type that can be encoded to base 64.
public protocol Base64StringEncodable {

  /// Encode data as a base64 encoded string.
  func encode() throws -> String
  func encodedImageDimensions() throws -> CGSize
  
  var encodedFormat: EncodedFormat { get }
}


