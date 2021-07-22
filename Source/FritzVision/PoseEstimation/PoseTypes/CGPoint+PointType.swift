//
//  Point.swift
//  FritzVision
//
//  Created by Christopher Kelly on 3/29/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

extension CGPoint {
  func squaredDistance(_ point: CGPoint) -> CGFloat {
    let dx = x - point.x
    let dy = y - point.y
    return dx * dx + dy * dy
  }
}

extension CGPoint: PointType {

  public func toArray() -> [Double] {
    return [Double(x), Double(y)]
  }

  public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }

  public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }

  public static func / (lhs: CGPoint, by: Double) -> CGPoint {
    return CGPoint(x: lhs.x / CGFloat(by), y: lhs.y / CGFloat(by))
  }

  public static func / (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
  }

  public static func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
  }

  public static func * (lhs: CGPoint, rhs: CGSize) -> CGPoint {
    return CGPoint(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
  }

  public static func / (lhs: CGPoint, rhs: CGSize) -> CGPoint {
    return CGPoint(x: lhs.x / rhs.width, y: lhs.y / rhs.height)
  }
}
