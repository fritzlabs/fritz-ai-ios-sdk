//
//  UIColor+rgbaValue.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/23/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public typealias rgbaValue = (r: UInt8, g: UInt8, b: UInt8, a: UInt8)

extension UIColor {
  /// Converts to rgbaValue type we use in most of the masking functions.
  var rgbaValue: rgbaValue? {
    guard let components = cgColor.components, components.count >= 3 else { return nil }
    if components.count == 4 {
      return (
        r: UInt8(components[0] * 255.0),
        g: UInt8(components[1] * 255.0),
        b: UInt8(components[2] * 255.0),
        a: UInt8(components[3] * 255.0)
      )
    } else {
      return (
        r: UInt8(components[0] * 255.0),
        g: UInt8(components[1] * 255.0),
        b: UInt8(components[2] * 255.0),
        a: 255
      )
    }
  }
}
