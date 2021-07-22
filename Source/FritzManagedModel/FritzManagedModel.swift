//
//  FritzManagedModel.swift
//  FritzManagedModel
//
//  Created by Christopher Kelly on 1/17/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public enum FritzManagedModelError: Error {
  case loadingSavedModelFailed
}

/// Coordinates tasks for interacting with Fritz Models.
@objcMembers
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class FritzManagedModel: NSObject {

  /// Currenly active model configuration.
  ///
  /// Note this this is a globally active config for a model.  If you have multiple FritzManagedModel
  /// instances and a new version is downloaded, all instances will be updated with the latest
  /// configuration..
  public private(set) var activeModelConfig: FritzModelConfiguration

  private let sessionManager: SessionManager

  /// List of fetch model requests waiting for model to be downloaded or loaded.
  private var fetchModelCompletionHandlers: [(FritzMLModel?, Error?) -> Void] = []

  private let fetchModelCompletionHandlersQueue = DispatchQueue(
    label: "com.fritz.sdk.fritz-managed-model.fetch-model-queue"
  )

  // Generally we don't make the logger's static, but it seems
  // there is a bug in the Swift compiler that prevents the class being
  // generated if there is a struct attached to the instance? Making it static fixes the
  // problem for now.
  private static let logger = Logger(name: "FritzManagedModel")

  /// Model Identifier of active model.
  public var id: String {
    return self.activeModelConfig.identifier
  }

  /// Model Version number of active model.
  public var version: Int {
    return self.activeModelConfig.version
  }

  /// If true, the active model config version is downloaded.
  public var isVersionDownloaded: Bool {
    if SessionManager.localModelManager.loadLocalModelInfo(activeModelConfig) != nil {
      return true
    }
    if let includedModel = packagedIdentifiedModelType,
      includedModel.packagedModelVersion == version
    {
      return true
    }
    return false
  }

  /// If true, there is at least one active model downloaded
  public var hasDownloadedModel: Bool {
    if SessionManager.localModelManager.loadActiveModelInfo(activeModelConfig) != nil {
      return true
    }
    if let _ = packagedIdentifiedModelType { return true }
    return false
  }

  /// The type of the identified model, if initialized from a conformed model.
  /// Storing this gives us access to the url of the identified model, so you can call
  /// self.loadModel() and load the model included in the package.
  public let packagedIdentifiedModelType: BaseIdentifiedModel.Type?

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  /// Creates FritzManagedModel from model configuration.
  ///
  /// - Parameters:
  ///   - modelConfig: Specifies which model class is operating on.
  ///   - sessionManager: Optional SessionManager. If not included uses default globally shared SessionManager.
  ///   - loadActiveFromDisk: If true (default) will load latest model downloaded over the air.
  ///   - packagedIdentifiedModelType: Optional identified model type packaged in app.
  @objc(initWithModelConfig:sessionManager:loadActive:packagedModelType:)
  public init(
    modelConfig: FritzModelConfiguration,
    sessionManager: SessionManager? = nil,
    loadActiveFromDisk: Bool = true,
    packagedIdentifiedModelType: BaseIdentifiedModel.Type? = nil
  ) {
    if loadActiveFromDisk,
      let activeConfig = SessionManager.localModelManager.loadActiveModelInfo(modelConfig)
    {
      // This is a bit sketchy, if we have previously saved a model with a wifi setting,
      // we're updating that setting here. I think this makes sense, as the wifi setting
      // you're loading with is more up to date, but a bit weird.
      activeConfig.wifiRequiredForModelDownload = modelConfig.wifiRequiredForModelDownload
      activeConfig.pinnedVersion = modelConfig.pinnedVersion
      self.activeModelConfig = activeConfig
    } else {
      self.activeModelConfig = modelConfig
    }
    self.sessionManager = sessionManager ?? FritzCore.configuration.sessionManager
    self.packagedIdentifiedModelType = packagedIdentifiedModelType
    super.init()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleActiveModelChangeNotification),
      name: .activeModelChanged,
      object: nil
    )
  }

  /// Creates FritzManagedModel from a packaged MLModel with BaseIdentifiedModel extension.  Used when model is included in application package.
  ///
  /// - Parameter identifiedModel: Included MLModel class.
  @objc(initWithIdentifiedModel:)
  public convenience init(identifiedModel: BaseIdentifiedModel) {
    let modelConfig = FritzModelConfiguration(from: identifiedModel)
    self.init(
      modelConfig: modelConfig,
      sessionManager: identifiedModel.configuration.sessionManager,
      packagedIdentifiedModelType: type(of: identifiedModel)
    )
  }

  /// Creates FritzManagedModel from a packaged MLModel with BaseIdentifiedModel extension.  Used when model is included in application package.
  ///
  /// - Parameter identifiedModelType: Type of conformed model.
  @objc(initWithIdentifiedModelType:)
  public convenience init(identifiedModelType: BaseIdentifiedModel.Type) {
    let modelConfig = FritzModelConfiguration(from: identifiedModelType)
    self.init(
      modelConfig: modelConfig,
      sessionManager: identifiedModelType.resolvedConfiguration.sessionManager,
      packagedIdentifiedModelType: identifiedModelType
    )
  }

  /// Deletes all state relating to managed model version.
  ///
  /// This removes all downloaded versions for this model identifier and any cached
  /// server values for it.
  public func delete() throws {
    try ServerModelCache.shared.remove(id)
    try SessionManager.localModelManager.removeModelDirectory(modelIdentifier: id)
  }

  /// Update active model config and fire notification for changed active model.
   fileprivate func updateActiveModelConfig(_ config: FritzModelConfiguration) {
     self.activeModelConfig = config
     NotificationCenter.default.post(name: .activeModelChanged, object: self)
   }
}

// MARK: - Handle Active Model Changes
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension FritzManagedModel {

  /// Handler for the actual model update notification, ensure updated model is our model
  @objc
  private func handleActiveModelChangeNotification(_ notification: Notification) {
    guard
      let managedModel = notification.object as? FritzManagedModel,
      self.activeModelConfig.identifier == managedModel.activeModelConfig.identifier,
      self.activeModelConfig.version != managedModel.activeModelConfig.version
    else { return }
    handleActiveModelChange(managedModel.activeModelConfig)
  }

  /// Swap out model when we have an updated version
  private func handleActiveModelChange(_ activeModelConfig: FritzModelConfiguration) {
    Self.logger.debug("Updating FritzManagedModel for:", activeModelConfig.identifier)
    self.activeModelConfig = activeModelConfig
  }
}

// MARK: - Load Model internal methods
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension FritzManagedModel {

  /// Load FritzMLModel from stored Fritz Model (as defined by active model metadata) or model included in app bundle.
  ///
  /// - Parameter identifiedModel: Conformed MLModel.
  /// - Returns: FritzMLModel.
  public func loadModel(identifiedModel: BaseIdentifiedModel) -> FritzMLModel {
    let model: MLModel = loadMLModel(identifiedModel: identifiedModel)
    return FritzMLModel(
      model: model,
      activeModelConfig: activeModelConfig,
      sessionManager: sessionManager
    )
  }

  /// Loads a model previously downloaded OTA if it exists.
  ///
  /// - Returns: nil if no model downloaded or FritzMLModel if it does.
  public func loadModel() -> FritzMLModel? {
    guard let localInfo = SessionManager.localModelManager.loadLocalModelInfo(activeModelConfig)
    else {
      guard let packagedIdentifiedModelType = packagedIdentifiedModelType,
        let modelURL = packagedIdentifiedModelType.urlOfModelInThisBundle
      else { return nil }

      guard let mlmodel = try? MLModel(contentsOf: modelURL) else { return nil }
      return FritzMLModel(
        model: mlmodel,
        activeModelConfig: activeModelConfig,
        sessionManager: sessionManager
      )
    }

    guard let model = loadSavedMLModel(localInfo) else { return nil }

    return FritzMLModel(
      model: model,
      activeModelConfig: activeModelConfig,
      sessionManager: sessionManager
    )
  }

  /// Loads model when no model is included in application bundle.  If a model has previously been downloaded, it will be used. If not, it will be downloaded from Fritz.
  ///
  /// If `fetchModel` is called multiple times and a download request is already happening, a new downloaded request will not be started.  All completionHandlers will be resolved when active request is completed.
  /// - Parameter completionHandler: Completion handler returning ManagedMLModel if successfully loaded model.
  public func fetchModel(completionHandler: @escaping (FritzMLModel?, Error?) -> Void) {
    fetchModelCompletionHandlersQueue.sync {
      fetchModelCompletionHandlers.append(completionHandler)
    }

    // Not 100% sure if it needs to be in the sync or not, I don't think so?
    if fetchModelCompletionHandlers.count > 1 {
      return
    }

    downloadAndFetchModel { managedModel, error in
      let callbacks = self.fetchModelCompletionHandlers
      self.fetchModelCompletionHandlersQueue.sync {
        self.fetchModelCompletionHandlers = []
      }

      for callback in callbacks {
        callback(managedModel, error)
      }
    }
  }

  /// Trigger model download without waiting for response.
  public func startDownload() {
    fetchModel { managedModel, error in
      guard let downloadedModel = managedModel else {
        Self.logger.error("Failed to download model: \(self.id)", error.debugDescription)
        return
      }
      Self.logger.info(
        "Finished downloading model: \(downloadedModel.id) - \(downloadedModel.version)"
      )
    }
  }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension FritzManagedModel {

  func downloadAndFetchModel(completionHandler: @escaping (FritzMLModel?, Error?) -> Void) {
    // Check to see if model already exists locally
    if let fritzModel = loadModel() {
      completionHandler(fritzModel, nil)
      return
    }

    sessionManager.download(activeModelConfig) {
      (localInfo: LocalModelInfo?, error: Error?) -> Void in
      guard let localModelInfo = localInfo else {
        completionHandler(nil, error)
        return
      }

      guard let model = self.loadSavedMLModel(localModelInfo) else {
        completionHandler(nil, FritzManagedModelError.loadingSavedModelFailed)
        return
      }

      // Downloaded model is different than active model version.
      if self.activeModelConfig.identifier == localModelInfo.id
        && self.activeModelConfig.version != localModelInfo.version
      {

        let newConfig = FritzModelConfiguration(
          from: localModelInfo,
          activeModelConfig: self.activeModelConfig
        )
        newConfig.wifiRequiredForModelDownload = self.activeModelConfig.wifiRequiredForModelDownload
        self.updateActiveModelConfig(newConfig)
      }

      do {
        try SessionManager.localModelManager.persistActive(
          self.activeModelConfig
        )
      } catch {
        Self.logger.error("Failed to persist active model config")
      }

      let fritzMLModel = FritzMLModel(
        model: model,
        activeModelConfig: self.activeModelConfig,
        sessionManager: self.sessionManager
      )

      completionHandler(fritzMLModel, nil)
    }
  }

  /// Loads previously downloaded model from disk or uses the identified model included in the app.
  ///
  /// - Parameter identifiedModel: Identified model included with bundle.
  ///
  /// - Returns: MLModel for activeModelConfig
  func loadMLModel(identifiedModel: BaseIdentifiedModel) -> MLModel {
    if activeModelConfig.version == identifiedModel.packagedModelVersion {
      return identifiedModel.model
    }
    guard let localInfo = SessionManager.localModelManager.loadLocalModelInfo(activeModelConfig)
    else {
      // If we don't have a local model, will have to default to included model.
      let activeModelConfig = FritzModelConfiguration(from: identifiedModel)
      updateActiveModelConfig(activeModelConfig)
      return identifiedModel.model
    }

    if localInfo.isModelCompiled, let model = loadSavedMLModel(localInfo) {
      return model
    }

    // If compiled model on disk fails to load, activeModelInfo is mutated to reflect prepackaged BaseIdentifiedModel.
    // Here the model version is different but we failed to load a saved model. Update model configuration as well.
    updateActiveModelConfig(FritzModelConfiguration(from: identifiedModel))
    return identifiedModel.model
  }

  func loadSavedMLModel(_ localInfo: LocalModelInfo) -> MLModel? {
    // NOTE: The compiled model URL that is stored in the info file is an absolute path.  When loading the model using the stored path, it loads the incorrect path (refers to an old UUID). When using the the compiled model URL from the localModelManager, it returns the correct url.
    let compiledModelURL = SessionManager.localModelManager.compiledModelURL(localInfo)
    sessionManager.logger.debug("Using OTA Model:", localInfo.id)
    do {

      if #available(iOS 12.0, *), activeModelConfig.cpuAndGPUOnly == true {
        // The Apple Neural Engine (ANE) takes much longer to load the image segmentation model and seems to actually take longer to run inference for this model. As a result, going to disable the ANE for this model. It would be better if there were an easier way to configure this, but for now I think this is the cleanest way of going about it.
        let modelConfig = MLModelConfiguration()
        modelConfig.computeUnits = .cpuAndGPU
        return try MLModel(contentsOf: compiledModelURL, configuration: modelConfig)
      } else {
        return try MLModel(contentsOf: compiledModelURL)
      }
    } catch {
      // If the MLModel fails to compile, overwrite included model as default so that we don't continue to attempt
      // to load a failed model.  This case should almost never happen.
      do {
        try SessionManager.localModelManager.removeLocalModelInfo(localInfo)
      } catch {
        sessionManager.logger.error("Unable to remove local model info to disk.")
      }

      sessionManager.logger.error("Failed to instantiate model from a previously compiled model")
      FritzError.post(
        session: sessionManager.session,
        modelIdentifier: localInfo.id,
        code: .modelInitialization,
        error: error
      )
      return nil
    }
  }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension FritzManagedModel {

  /// Check server for latest active model defined in webapp and update local model state if different from webapp.
  ///
  /// If a model is updated, an .activeModelChanged notification is broadcast.
  ///
  /// - Parameter completionHandler: Completion handler called with result of update operation.
  public func updateModelIfNeeded(
    skipCache: Bool = false,
    completionHandler: @escaping (Bool, Error?) -> Void
  ) {
    Self.logger.debug("Update Model:", id, version)
    isNewerModelAvailable(skipCache: skipCache) { result, error in
      guard let result = result else {
        return completionHandler(false, error)
      }
      guard result.updateAvailable else {
        return completionHandler(false, nil)
      }

      let activeServerModel = result.activeServerModel
      let newActiveModelConfig = FritzModelConfiguration(
        from: result.activeServerModel,
        modelConfig: self.activeModelConfig
      )

      self.sessionManager.downloadAndCompileModel(
        for: newActiveModelConfig,
        serverModelInfo: activeServerModel
      ) { localInfo, error in
        guard let localModelInfo = localInfo else {
          completionHandler(error == nil, error)
          return
        }

        let activeModelConfig = FritzModelConfiguration(
          from: localModelInfo,
          activeModelConfig: newActiveModelConfig
        )
        do {
          try SessionManager.localModelManager.persistActive(
            activeModelConfig
          )
          self.updateActiveModelConfig(activeModelConfig)
          completionHandler(true, nil)
        } catch {
          completionHandler(false, error)
        }
      }
    }
  }

  /// Check to see if active model needs to be changed based on response from Fritz API.
  ///
  /// - Parameter completionHandler: Completion handler called after server respose received.
  internal func isNewerModelAvailable(
    skipCache: Bool = false,
    completionHandler: @escaping (
      (activeServerModel: ActiveServerModel, updateAvailable: Bool)?, Error?
    ) -> Void
  ) {
    sessionManager.readServerModel(activeModelConfig, checkCache: !skipCache) {
      serverModel,
      error in
      guard let serverModel = serverModel else {
        return completionHandler(nil, error)
      }

      let result = (serverModel, serverModel.version != self.activeModelConfig.version)
      completionHandler(result, nil)
    }
  }
}
