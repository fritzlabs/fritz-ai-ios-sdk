//
//  Keypoint.swift
//  FritzVision
//
//  Created by Christopher Kelly on 3/29/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Predicted keypoint containing part, score, and position identified.
public class Keypoint<Skeleton: SkeletonType>: NSObject, KeypointType {

  public let index: Int
  public let position: CGPoint
  public let score: Double
  public let part: Skeleton

  public required init(index: Int, position: CGPoint, score: Double, part: Skeleton) {
    self.index = index
    self.position = position
    self.score = score
    self.part = part
  }

  public override var description: String {
    let formattedScore = String(format: "%.3f", score)
    return "Keypoint(id: \(index), position: \(position), score: \(formattedScore), part: \(part))"
  }

  /// Creates keypoint from Point.
  /// - Parameter position: Point
  public func fromPosition(_ position: CGPoint) -> Self {
    return .init(index: index, position: position, score: score, part: part)
  }

  public func to3D() -> Keypoint3D<Skeleton> {
    return Keypoint3D(
      index: index,
      position: Point3D(x: position.x, y: position.y, z: 0.0),
      score: score,
      part: part
    )

  }

  override public func isEqual(_ object: Any?) -> Bool {

    if let object = object as? Keypoint<Skeleton> {
      let areEqual = index == object.index && position == object.position && score == object.score
        && part == object.part

      return areEqual
    }
    return false
  }

  public func normalized(by size: CGSize) -> Keypoint {
    let newPosition = CGPoint(x: position.x / size.width, y: position.y / size.height)
    return Keypoint<Skeleton>(index: index, position: newPosition, score: score, part: part)
  }
}

public func == <Skeleton: SkeletonType>(lhs: Keypoint<Skeleton>, rhs: Keypoint<Skeleton>) -> Bool {
  let areEqual = lhs.index == rhs.index && lhs.position == rhs.position && lhs.score == rhs.score
    &&  // TODO: Figure this out...
    lhs.part == rhs.part

  return areEqual
}
