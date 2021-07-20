//
//  KeypointType.swift
//  FritzVision
//
//  Created by Christopher Kelly on 8/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public protocol KeypointType: AnyObject, Equatable {
  associatedtype Point: PointType
  associatedtype Skeleton: SkeletonType

  var index: Int { get }
  var position: Point { get }
  var score: Double { get }

  init(index: Int, position: Point, score: Double, part: Skeleton)

  func fromPosition(_ position: Point) -> Self
}
