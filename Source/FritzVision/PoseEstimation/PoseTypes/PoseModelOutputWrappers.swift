//
//  PoseTypes.swift
//  FritzVision
//
//  Created by Christopher Kelly on 2/4/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public struct HeatmapPoint {
  let x: Int
  let y: Int
}

struct Part {
  let heatmapX: Int
  let heatmapY: Int
  let id: Int

  public init(x: Int, y: Int, keypointID: Int) {
    self.heatmapX = x
    self.heatmapY = y
    id = keypointID
  }
}

extension HeatmapPoint {
  func squaredDistance(_ point: HeatmapPoint) -> Int {
    let dx = self.x - point.x
    let dy = self.y - point.y
    return dx * dx + dy * dy
  }
}

///  `[height, width, 2 * num_edges]`, where `num_edges = num_parts - 1` is the
///  number of edges (parent-child pairs) in the tree. It contains the forward
///  displacements between consecutive part from the root towards the leaves.
@available(iOS 11.0, *)
public class Displacements {

  let displacements: MultiArray<Double>

  var numEdges: Int {
    return Int(displacements.shape[0] / 2)
  }

  var height: Int {
    return displacements.shape[1]
  }

  var width: Int {
    return displacements.shape[2]
  }

  public init(for results: MLMultiArray?) {
    self.displacements = MultiArray<Double>(results!)
  }

  public subscript(point: HeatmapPoint, edgeID: Int, offset: OffsetType) -> Double {
    get {
      switch offset {
      case .y: return displacements[edgeID, point.y, point.x]
      case .x: return displacements[edgeID + numEdges, point.y, point.x]
      }
    }
  }

  public func sum() -> Double {
    var total: Double = 0.0
    for i in 0..<self.displacements.count {
      total += self.displacements[i]
    }
    return total
  }
}

// * @param heatmapScores 3-D tensor with shape `[height, width, numParts]`.
// * The value of heatmapScores[y, x, k]` is the score of placing the `k`-th
// * object part at position `(y, x)`.
@available(iOS 11.0, *)
public class HeatmapScores {

  let scores: MultiArray<Double>

  var numKeypoints: Int {
    return scores.shape[0]
  }

  var height: Int {
    return scores.shape[1]
  }

  var width: Int {
    return scores.shape[2]
  }

  public init(for results: MLMultiArray?) {
    self.scores = MultiArray<Double>(results!)
  }

  public subscript(point: HeatmapPoint, partID: Int) -> Double {
    get { return scores[partID, point.y, point.x] }
  }

  public subscript(y: Int, x: Int, keypointID: Int) -> Double {
    get { return scores[keypointID, y, x] }
  }

  public func sum() -> Double {
    var total: Double = 0.0
    for i in 0..<self.scores.count {
      total += self.scores[i]
    }
    return total
  }
}

public enum OffsetType {
  case x
  case y
}

// * @param offsets 3-D tensor with shape `[height, width, numParts * 2]`.
// * The value of [offsets[y, x, k], offsets[y, x, k + numParts]]` is the
// * short range offset vector of the `k`-th  object part at heatmap
// * position `(y, x)`.
@available(iOS 11.0, *)
public class Offsets {

  let offsets: MultiArray<Double>

  var numPoints: Int {
    return offsets.shape[0] / 2
  }

  var height: Int {
    return offsets.shape[1]
  }

  var width: Int {
    return offsets.shape[2]
  }

  public init(for results: MLMultiArray?) {
    self.offsets = MultiArray<Double>(results!)
  }

  public func get(y: Int, x: Int, partID: Int, offset: OffsetType) -> Double {
    switch offset {
    case .y: return offsets[partID, y, x]
    case .x: return offsets[partID + numPoints, y, x]
    }
  }

  public func sum() -> Double {
    var total: Double = 0.0
    for i in 0..<self.offsets.count {
      total += self.offsets[i]
    }
    return total
  }
}

// * @param offsets 3-D tensor with shape `[height, width, numParts * 2]`.
// * The value of [offsets[y, x, k], offsets[y, x, k + numParts]]` is the
// * short range offset vector of the `k`-th  object part at heatmap
// * position `(y, x)`.
@available(iOS 11.0, *)
public class Segments {

  let results: MultiArray<Double>

  var height: Int {
    return results.shape[1]
  }

  var width: Int {
    return results.shape[2]
  }

  public init(for results: MLMultiArray?) {
    self.results = MultiArray<Double>(results!)
  }

  public subscript(point: HeatmapPoint) -> Double {
    get { return results[0, point.y, point.x] }
  }

  public subscript(y: Int, x: Int) -> Double {
    get { return results[0, y, x] }
  }

  public func sum() -> Double {
    var total: Double = 0.0
    for i in 0..<self.results.count {
      total += self.results[i]
    }
    return total
  }
}
