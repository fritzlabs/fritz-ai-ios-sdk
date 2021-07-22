//
//  FritzImageProvider.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/2/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Able to run predictions on a FritzVisionImage
@available(iOS 11.0, *)
public protocol FritzVisionImagePredictable: FritzPredictable
where PredictionInput: FritzVisionImage, ModelOptions: FritzImageOptions {

  func predict(
    _ input: PredictionInput,
    options: ModelOptions,
    completion: (PredictionResult?, Error?) -> Void
  )
}
