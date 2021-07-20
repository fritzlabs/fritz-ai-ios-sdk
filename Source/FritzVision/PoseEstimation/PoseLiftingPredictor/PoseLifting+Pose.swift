//
//  PoseLifting+Pose.swift
//  FritzVision
//
//  Created by Christopher Kelly on 3/27/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
extension Pose where Skeleton == HumanSkeleton {

  public func getHipCenter() -> CGPoint? {
    guard let leftHip = getKeypoint(for: .leftHip),
      let rightHip = getKeypoint(for: .rightHip)
    else {
      return nil
    }
    return (leftHip.position + rightHip.position) / 2.0
  }

  public func translate() -> [CGPoint]? {
    guard let hipCenter = getHipCenter() else { return nil }
    return keypoints.map { $0.position - hipCenter }
  }

  public func translateKeypoint() -> [Keypoint<Skeleton>]? {
    guard let hipCenter = getHipCenter() else { return nil }
    return keypoints.map {
      Keypoint(index: $0.index, position: $0.position - hipCenter, score: $0.score, part: $0.part)
    }
  }

  public func getInputKeypoints(translate: Bool = true) -> [Keypoint<Skeleton>]? {
    guard let hipCenter = getHipCenter() else { return nil }
    var modelInputs: [Keypoint<Skeleton>] = []

    for modelPart in PosePreprocessing.modelInputPartOrder {
      guard let keypoint = getKeypoint(for: modelPart) else {
        print("No keypoint for \(modelPart), not using this pose.")
        return nil
      }

      if translate {
        let translated = Keypoint(
          index: keypoint.index,
          position: keypoint.position - hipCenter,
          score: keypoint.score,
          part: keypoint.part
        )
        modelInputs.append(translated)
      } else {
        modelInputs.append(keypoint)
      }
    }
    return modelInputs
  }
}
