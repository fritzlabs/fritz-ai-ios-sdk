//
//  BasePredictor.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/9/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
open class BasePredictor: NSObject, FritzMLModelReadType, FritzManagedModelType {

  public let model: FritzMLModel

  @objc public let managedModel: FritzManagedModel

  /// Initialize model with FritzMLModel
  ///
  /// - Parameter model: FritzMLModel
  @objc(initWithModel:)
  public init(model: FritzMLModel) {
    self.model = model
    self.managedModel
      = FritzManagedModel(
        modelConfig: model.activeModelConfig,
        sessionManager: model.sessionManager,
        loadActiveFromDisk: false
      )
  }

  /// Initialize model with FritzMLModel
  ///
  /// - Parameter model: FritzMLModel
  @objc(initWithModel:managedModel:)
  public init(model: FritzMLModel, managedModel: FritzManagedModel) {
    self.model = model
    self.managedModel = managedModel
  }

  @objc(initWithIdentifiedModel:)
  public init(model: SwiftIdentifiedModel) {
    self.model = model.fritzModel()
    self.managedModel = FritzManagedModel(identifiedModel: model)
  }

  /// Model metadata set in webapp.
  @objc public var metadata: ModelMetadata? {
    return model.activeModelConfig.metadata
  }

  /// Model tags set in webapp.
  @objc public var tags: [String]? {
    return model.activeModelConfig.tags
  }
}
