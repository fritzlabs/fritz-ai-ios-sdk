//
//  FritzVisionError.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/8/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@objc public enum FritzVisionError: Int, Error {
  case invalidImageBuffer
  case errorProcessingImage
  case imageNotEncodable
}
