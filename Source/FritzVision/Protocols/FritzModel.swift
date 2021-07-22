//
//  FritzPredictor.swift
//  Fritz
//
//  Created by Christopher Kelly on 2/6/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import Vision

@available(iOS 11.0, *)
protocol FritzMLModelReadType {
  var model: FritzMLModel { get }
}

@available(iOS 11.0, *)
public protocol FritzManagedModelType {

  var managedModel: FritzManagedModel { get }

  var metadata: [String: String]? { get }

  var tags: [String]? { get }
}
