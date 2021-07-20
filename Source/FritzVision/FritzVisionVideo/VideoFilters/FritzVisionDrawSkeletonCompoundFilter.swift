//
//  FritzVisionDrawSkeletonCompoundFilter.swift
//  FritzVision
//
//  Created by Steven Yeung on 10/29/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Draws human pose skeletons on detected people.
@available(iOS 11.0, *)
public class FritzVisionDrawSkeletonCompoundFilter: FritzVisionImageFilter {

  public let compositionMode = FilterCompositionMode.compoundWithPreviousOutput
  public let model: FritzVisionHumanPosePredictor
  public let options: FritzVisionPoseModelOptions

  public init(
    model: FritzVisionHumanPosePredictor,
    options: FritzVisionPoseModelOptions = .init()
  ) {
    self.model = model
    self.options = options
  }

  public func process(_ image: FritzVisionImage) -> FritzVisionFilterResult {
    do {
      let poseResult = try self.model.predict(image, options: options)
      if let pose = poseResult.pose(),
        let drawnPose = image.draw(pose: pose)
      {
        return .success(FritzVisionImage(image: drawnPose))
      }
      return .success(image)
    } catch let error {
      return .failure(error)
    }
  }
}
