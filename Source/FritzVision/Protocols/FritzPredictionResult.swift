//
//  FritzPredictionOutput.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/2/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public protocol FritzPredictionResult {}

@available(iOS 11.0, *)
extension Array: FritzPredictionResult where Element: FritzPredictionResult {}

extension CVPixelBuffer: FritzPredictionResult {}
