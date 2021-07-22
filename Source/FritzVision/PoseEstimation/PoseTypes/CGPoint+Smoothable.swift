//
//  CGPoint+Smoothable.swift
//  FritzVision
//
//  Created by Christopher Kelly on 8/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

extension CGPoint {

  public init(point: SmoothingPoint) {
    self.init(x: point.xAccel, y: point.yAccel)
  }

  public func buildAccelPoint(count: Int) -> SmoothingPoint {
    return SmoothingPoint(
      dataX: Double(x),
      dataY: Double(y),
      dataZ: 0.0,
      count: count
    )
  }
}

extension CGPoint: ArrayInitializable {

  public init(with array: [CGFloat]) {
    self.init(x: array[0], y: array[1])
  }
}

public class PoseSmoothingOptions {
  let frequency: Double
  let minCutoff: Double
  let beta: Double
  let derivateCutoff: Double

  public init(
    frequency: Double = 1.0,
    minCutoff: Double = 1.0,
    beta: Double = 0.0,
    derivateCutoff: Double = 1.0
  ) {
    self.frequency = frequency
    self.minCutoff = minCutoff
    self.beta = beta
    self.derivateCutoff = derivateCutoff
  }
}
