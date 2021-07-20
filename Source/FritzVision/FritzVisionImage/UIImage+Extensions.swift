//
//  UIImage+Extensions.swift
//  FritzVision
//
//  Created by Christopher Kelly on 10/8/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

extension UIImage {
  /// Returns a UIImage that is backed by a CGImage.
  var imageBackedByCIImage: UIImage {
    if let _ = ciImage {
      return self
    } else if let cgImage = cgImage {
      return UIImage(ciImage: CIImage(cgImage: cgImage))
    }
    return self
  }
}
