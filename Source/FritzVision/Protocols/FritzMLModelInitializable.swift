//
//  InitializableModel.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/2/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Model that can be initialized purely from various forms of FritzMLModels
@available(iOS 11.0, *)
public protocol FritzMLModelInitializable {

  init(model: FritzMLModel) throws

  init(model: SwiftIdentifiedModel) throws

  init(model: FritzMLModel, managedModel: FritzManagedModel) throws
}
