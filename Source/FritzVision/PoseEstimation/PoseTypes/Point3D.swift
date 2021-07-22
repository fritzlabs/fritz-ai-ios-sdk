//
//  Point3D.swift
//  FritzVision
//
//  Created by Christopher Kelly on 3/29/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@objcMembers
public final class Point3D: NSObject, PointType {
  public let x: CGFloat
  public let y: CGFloat
  public let z: CGFloat

  public init(x: CGFloat, y: CGFloat, z: CGFloat) {
    self.x = x
    self.y = y
    self.z = z
  }

  public override var description: String {
    let x = String(format: "%.10f", self.x)
    let y = String(format: "%.10f", self.y)
    let z = String(format: "%.10f", self.z)
    return "(x: \(x), y: \(y), z: \(z))"
  }

  public func toArray() -> [Double] {
    return [x, y, z].map { Double($0) }
  }
}

extension Point3D {
  public static func - (lhs: Point3D, rhs: Point3D) -> Point3D {
    return Point3D(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
  }

  public static func + (lhs: Point3D, rhs: Point3D) -> Point3D {
    return Point3D(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
  }

  public static func / (lhs: Point3D, rhs: CGFloat) -> Point3D {
    return Point3D(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
  }

  public static func / (lhs: Point3D, rhs: Double) -> Point3D {
    return lhs / CGFloat(rhs)
  }

  public static func / (lhs: Point3D, rhs: Point3D) -> Point3D {
    return Point3D(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z)
  }

  public static func * (lhs: Point3D, rhs: Point3D) -> Point3D {
    return Point3D(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
  }
}

public func == (lhs: Point3D, rhs: Point3D) -> Bool {
  let areEqual = lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z

  return areEqual
}
