//
//  SkeletonType.swift
//  FritzVision
//
//  Created by Christopher Kelly on 8/30/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public typealias ConnectedPart<Skeleton: SkeletonType> = (Skeleton, Skeleton)

public protocol SkeletonType: CaseIterable, RawRepresentable, Equatable {

  init?(rawValue: Int)

  var rawValue: Int { get }

  /// A label describing the name of the object the pose skeleton represents.
  ///
  /// The ``objectName`` is used to identify objects for data collection.  When recording
  /// predictions, this name will be used to identify an object. 
  static var objectName: String { get }

  static var connectedParts: [ConnectedPart<Self>] { get }
  static var poseChain: [ConnectedPart<Self>] { get }

}

extension SkeletonType {

  public static var numParts: Int {
    return self.allCases.count
  }

  public static var connectedParts: [ConnectedPart<Self>] {
    let parts = self.allCases.map { $0 }
    var connectedParts = [ConnectedPart<Self>]()
    for (i, part) in parts.enumerated() {
      if i == parts.count - 1 {
        break
      }
      connectedParts.append((part, parts[i + 1]))
    }
    return connectedParts
  }

  public static var poseChain: [ConnectedPart<Self>] {
    return connectedParts
  }

  public static var parentChildTuples: [ConnectedPart<Self>] {
    return poseChain.map { (jointA, jointB) in
      (Self.init(rawValue: jointA.rawValue)!, Self.init(rawValue: jointB.rawValue)!)
    }
  }

  public static var parentToChildEdges: [Self] {
    return parentChildTuples.map { (_, part1) in
      part1
    }
  }

  public static var childToParentEdges: [Self] {
    return parentChildTuples.map { (part0, _) in
      part0
    }
  }

  public static func getConnectedKeypoints<Skeleton: SkeletonType>(
    keypoints: [Keypoint<Skeleton>],
    minConfidence: Double
  ) -> [(left: Keypoint<Skeleton>, right: Keypoint<Skeleton>)] {
    return Skeleton.connectedParts.map { (arg) in
      let left = arg.0
      let right = arg.1
      return (left: keypoints[left.rawValue], right: keypoints[right.rawValue])
    }.filter { $0.left.score >= minConfidence && $0.right.score >= minConfidence }
  }

}
