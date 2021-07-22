//
//  FritzPredictionInput.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/2/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public protocol FritzPredictionInput: class {}

@available(iOS 11.0, *)
extension FritzVisionImage: FritzPredictionInput {}
