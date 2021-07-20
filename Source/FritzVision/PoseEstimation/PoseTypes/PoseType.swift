//
//  PoseTypeProtocol.swift
//  FritzVision
//
//  Created by Christopher Kelly on 8/9/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public protocol PoseType: AnyObject {

  associatedtype Skeleton: SkeletonType
  associatedtype Keypoint: KeypointType

  init(keypoints: [Keypoint], score: Double, bounds: CGSize)

  var keypoints: [Keypoint] { get }
  var score: Double { get }
  var bounds: CGSize { get }

  func getPosition<Point: PointType>(of part: Skeleton) -> Point?
}

extension PoseType {

  public func getPosition<Point>(of part: Skeleton) -> Point? where Point: PointType {

    guard let index = keypoints.firstIndex(where: { $0.index == part.rawValue }) else {
      return nil
    }

    // hacky...
    return keypoints[index].position as? Point
  }
}
