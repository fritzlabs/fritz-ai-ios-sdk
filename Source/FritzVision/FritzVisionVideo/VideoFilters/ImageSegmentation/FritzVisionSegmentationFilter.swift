//
//  FritzVisionSegmentationFilter.swift
//  FritzVision
//
//  Created by Steven Yeung on 10/29/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
public protocol FritzVisionSegmentationFilter: FritzVisionImageFilter {

  var model: FritzVisionSegmentationPredictor { get }
}
