//
//  ManagedMLModel.swift
//  Fritz
//
//  Created by Andrew Barba on 9/19/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import CoreML
import FritzCore

internal let reportInstallKey = "com.fritz.sdk.installed-models"

@objc(FritzMLModel)
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public final class FritzMLModel: MLModel {

  @objc
  public private(set) var activeModelConfig: FritzModelConfiguration

  public var id: String {
    return self.activeModelConfig.identifier
  }

  public var version: Int {
    return self.activeModelConfig.version
  }

  /// Model manager for api requests
  unowned public let sessionManager: SessionManager

  /// Model to use for predictions
  public private(set) var model: MLModel

  /// Private logger instance
  private static let logger = Logger(name: "ManagedMLModel")

  private var logger: Logger {
    return type(of: self).logger
  }

  /// Initialize model with an model type.
  ///
  /// Listens for active model updates and reloads model if active version different than existing.
  @objc(initWithIdentifiedModel:config:sessionManager:)
  public init(
    model: MLModel,
    activeModelConfig: FritzModelConfiguration,
    sessionManager: SessionManager
  ) {
    self.model = model
    self.sessionManager = sessionManager
    self.activeModelConfig = activeModelConfig
    super.init()

    reportInstall()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleActiveModelChangedNotfication),
      name: .activeModelChanged,
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  /// Handler for the actual model update notification, ensure updated model is our model
  @objc private func handleActiveModelChangedNotfication(_ notification: Notification) {
    guard
      let managedModel = notification.object as? FritzManagedModel,
      self.activeModelConfig.identifier == managedModel.id,
      self.activeModelConfig.version != managedModel.version
    else { return }
    handleActiveModelChanged(managedModel)
  }

  /// Swap out model when we have an updated version
  private func handleActiveModelChanged(_ managedModel: FritzManagedModel) {
    logger.debug(
      "Model Updated: \(managedModel.id) \(activeModelConfig.version) -> \(managedModel.version)"
    )
    managedModel.fetchModel { updatedManagedMLModel, error in
      guard let newModel = updatedManagedMLModel else {
        self.logger.error("Failed to load saved model: \(managedModel.id) \(managedModel.version)")
        return
      }
      self.activeModelConfig = managedModel.activeModelConfig
      self.model = newModel
    }
  }

  /// Proxy model description
  public override var modelDescription: MLModelDescription {
    return model.modelDescription
  }

  /// Override prediction method and pass input/output to analytics
  @objc(predictionFromFeatures:error:)
  public override func prediction(from input: MLFeatureProvider) throws -> MLFeatureProvider {
    let result = PredictionResult(input: input, options: nil) { try model.prediction(from: input) }
    sessionManager.measurePrediction(result, forManagedModel: self)
    sessionManager.sampleInputOutput(result, forManagedModel: self)
    return try result.predictionResult()
  }

  /// Override prediction method and pass input/output to analytics
  @objc(predictionFromFeatures:options:error:)
  public override func prediction(from input: MLFeatureProvider, options: MLPredictionOptions)
    throws -> MLFeatureProvider
  {
    let result = PredictionResult(input: input, options: options) {
      try model.prediction(from: input, options: options)

    }
    sessionManager.measurePrediction(result, forManagedModel: self)
    sessionManager.sampleInputOutput(result, forManagedModel: self)
    return try result.predictionResult()
  }

  /// Returns latest version we have successfully reported to server
  private var lastReportedInstallVersion: Int? {
    get {
      let installs = UserDefaults.standard.dictionary(forKey: reportInstallKey)
      return installs?[id] as? Int
    }
    set {
      var installs = UserDefaults.standard.dictionary(forKey: reportInstallKey) ?? [String: Int]()
      installs[id] = newValue
      UserDefaults.standard.set(installs, forKey: reportInstallKey)
      UserDefaults.standard.synchronize()
    }
  }

  /// Reports install for the model if we have not reported an install before for that version
  private func reportInstall() {
    guard lastReportedInstallVersion != version else { return }

    sessionManager.reportInstall(forManagedModel: self)
    lastReportedInstallVersion = version
  }
}
