//
//  OneEuroFilter.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/5/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

class LowPassFilter {

  var lastRawValue: Double
  var smoothedResult: Double
  var alpha: Double
  var initialized = false

  init(alpha: Double, y: Double = 0, s: Double = 0) {
    self.lastRawValue = y
    self.smoothedResult = s
    self.alpha = alpha
  }

  func filter(value: Double) -> Double {
    // Don't update filter if the last value was a NaN
    if value.isNaN {
      return value
    }

    var result: Double!
    if !initialized {
      initialized = true
      result = value
    } else {
      result = alpha * value + (1.0 - alpha) * smoothedResult
    }

    lastRawValue = value
    smoothedResult = result
    return result
  }

  func filterWithAlpha(value: Double, alpha: Double) -> Double {
    self.alpha = alpha
    return filter(value: value)

  }
}

class OneEuroFilter {

  /// Small  value to add to frequency to prevent NaNs if the time is the same
  let epsilon = 1.0e-6

  var frequency: Double
  var minCutoff: Double
  var beta: Double
  var derivateCutoff: Double

  let x: LowPassFilter
  let dx: LowPassFilter

  var lastTime: Date?

  class func alpha(cutoff: Double, frequency: Double) -> Double {
    let te = 1.0 / frequency
    let tau = 1.0 / (2.0 * .pi * cutoff)
    return 1.0 / (1.0 + tau / te)
  }

  func alpha(cutoff: Double) -> Double {
    return OneEuroFilter.alpha(cutoff: cutoff, frequency: frequency)
  }

  init(
    frequency: Double = 1.0,
    minCutoff: Double = 1.0,
    beta: Double = 0.0,
    derivateCutoff: Double = 1.0
  ) {
    self.frequency = frequency
    self.minCutoff = minCutoff
    self.beta = beta
    self.derivateCutoff = derivateCutoff
    let minCutoffAlpha = OneEuroFilter.alpha(cutoff: minCutoff, frequency: frequency)
    let derivateAlpha = OneEuroFilter.alpha(cutoff: derivateCutoff, frequency: frequency)
    x = LowPassFilter(alpha: minCutoffAlpha)
    dx = LowPassFilter(alpha: derivateAlpha)
  }

  func filter(value: Double, timestamp: Date?) -> Double {
    if let lastTime = lastTime, let timestamp = timestamp {
      frequency = 1.0 / (timestamp.timeIntervalSince(lastTime) + epsilon)
    }
    lastTime = timestamp

    let dValue = x.initialized ? (value - x.lastRawValue) * frequency : 0.0
    let edValue = dx.filterWithAlpha(
      value: dValue,
      alpha: alpha(cutoff: dValue)
    )
    let cutoff = minCutoff + beta * abs(edValue)
    return x.filterWithAlpha(value: value, alpha: alpha(cutoff: cutoff))
  }
}

/// One Euro filter for a 2D or 3D point.
@objcMembers
public class OneEuroFilterPointable<Point: ArrayInitializable>: NSObject, PointFilterable {

  let currentFilters: [OneEuroFilter]

  public final class Options: FilterOptions {

    public let frequency: Double
    public let minCutoff: Double
    public let beta: Double
    public let derivateCutoff: Double

    public init(
      frequency: Double = 1.0,
      minCutoff: Double = 1.0,
      beta: Double = 0.0,
      derivateCutoff: Double = 0.0
    ) {
      self.frequency = frequency
      self.minCutoff = minCutoff
      self.beta = beta
      self.derivateCutoff = derivateCutoff
    }

    public required init() {
      self.frequency = 1.0
      self.minCutoff = 1.0
      self.beta = 0.0
      self.derivateCutoff = 0.0
    }
  }

  public required init(options: Options = .init()) {
    var currentFilters = [OneEuroFilter]()

    // This array lets us initialize either 2D or 3D points. A bit hacky
    // but allows for better generic handling.
    let emptyPointArray: [CGFloat] = [0.0, 0.0, 0.0]
    for _ in 0..<Point(with: emptyPointArray).toArray().count {
      currentFilters.append(
        OneEuroFilter(
          frequency: options.frequency,
          minCutoff: options.minCutoff,
          beta: options.beta,
          derivateCutoff: options.derivateCutoff
        )
      )
    }

    self.currentFilters = currentFilters
  }

  /// Filter point.
  ///
  /// - Parameter point: Input Point.
  /// - Returns: Point after original filter processing.
  public func filter(_ point: Point) -> Point {
    let currentValue = point.toArray()
    var newValues = [CGFloat]()
    for (i, value) in currentValue.enumerated() {
      let filter = currentFilters[i]
      let result = filter.filter(value: value, timestamp: Date())
      newValues.append(CGFloat(result))
    }

    return Point(with: newValues)
  }
}

public class OneEuroPointFilter: OneEuroFilterPointable<CGPoint> {

  public static let low = Options(
    frequency: 1.0,
    minCutoff: 1.0,
    beta: 0.1,
    derivateCutoff: 1.0
  )
}
