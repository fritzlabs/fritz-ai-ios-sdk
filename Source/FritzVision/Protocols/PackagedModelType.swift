//
//  PackagedModelType.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/9/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// The methods adopted by the object used to instantiate a predictor that
/// includes a model in the app bundle.
@available(iOS 12.0, *)
public protocol PackagedModelType {

  init()

}
