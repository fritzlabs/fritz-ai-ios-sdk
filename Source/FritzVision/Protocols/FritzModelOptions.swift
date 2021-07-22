//
//  FritzModelOptions.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/2/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public protocol FritzPredictorOptionType {
  init()
}

// MARK - Fritz Image Predictor options
public protocol FritzImageOptions: FritzPredictorOptionType {

  static var defaults: FritzImageOptions { get }

  var imageCropAndScaleOption: FritzVisionCropAndScale { get }

  var forceCoreMLPrediction: Bool { get }

  var forceVisionPrediction: Bool { get }
}
