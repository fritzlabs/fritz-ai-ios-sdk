//
//  Keypoint3D.swift
//  FritzVision
//
//  Created by Christopher Kelly on 8/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Predicted keypoint containing part, score, and position identified.
public final class Keypoint3D<Skeleton: SkeletonType>: NSObject, KeypointType {

  public let index: Int
  public let position: Point3D
  public let score: Double
  public let part: Skeleton

  public init(index: Int, position: Point3D, score: Double, part: Skeleton) {
    self.index = index
    self.position = position
    self.score = score
    self.part = part
  }

  public override var description: String {
    let formattedScore = String(format: "%.3f", score)
    return "Keypoint(id: \(index), position: \(position), score: \(formattedScore), part: \(part))"
  }

  public func fromPosition(_ position: Point3D) -> Keypoint3D {
    return Keypoint3D(
      index: index,
      position: position,
      score: score,
      part: part
    )
  }

  override public func isEqual(_ object: Any?) -> Bool {
    if let rhs = object as? Keypoint3D {
      let areEqual = index == rhs.index && position == rhs.position && score == rhs.score
        && part == rhs.part

      return areEqual
    }
    return false
  }
}

public func == <Skeleton: SkeletonType>(lhs: Keypoint3D<Skeleton>, rhs: Keypoint3D<Skeleton>)
  -> Bool
{
  let areEqual = lhs.index == rhs.index && lhs.position == rhs.position && lhs.score == rhs.score
    && lhs.part == rhs.part

  return areEqual
}
