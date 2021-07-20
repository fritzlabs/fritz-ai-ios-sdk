//
//  SmoothingPointable.swift
//  Fritz
//
//  Created by Christopher Kelly on 8/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// The methods used to initialize and convert points to and from SmoothingPoints used
/// in Savitzky-Golay filter.
public protocol SmoothingPointable: PointType {
  init(_ point: SmoothingPoint)
  func buildSmoothingPoint(count: Int) -> SmoothingPoint
}

extension Point3D: SmoothingPointable {

  public convenience init(_ point: SmoothingPoint) {
    self.init(x: CGFloat(point.xAccel), y: CGFloat(point.yAccel), z: CGFloat(point.zAccel))
  }

  public func buildSmoothingPoint(count: Int) -> SmoothingPoint {
    return SmoothingPoint(
      dataX: Double(x),
      dataY: Double(y),
      dataZ: Double(z),
      count: count
    )
  }
}

extension CGPoint: SmoothingPointable {

  public init(_ point: SmoothingPoint) {
    self.init(x: CGFloat(point.xAccel), y: CGFloat(point.yAccel))
  }

  public func buildSmoothingPoint(count: Int) -> SmoothingPoint {
    return SmoothingPoint(
      dataX: Double(x),
      dataY: Double(y),
      dataZ: 0.0,
      count: count
    )
  }
}
