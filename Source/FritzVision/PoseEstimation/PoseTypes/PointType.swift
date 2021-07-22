//
//  PointType.swift
//  FritzVision
//
//  Created by Christopher Kelly on 8/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public protocol PointType {

  func toArray() -> [Double]

  static func - (lhs: Self, rhs: Self) -> Self
  static func / (lhs: Self, rhs: Self) -> Self
  static func / (lhs: Self, rhs: Double) -> Self
  static func * (lhs: Self, rhs: Self) -> Self
}
