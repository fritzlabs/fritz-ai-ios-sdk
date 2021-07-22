//
//  SessionManager+FritzManagedModel.swift
//  FritzManagedModel
//
//  Contains operations relating to managing local stored model state.
//
//  Created by Christopher Kelly on 1/19/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SessionManager {

  /// Local model manager
  static let localModelManager: LocalModelManager = {
    // swiftlint:disable:next force_try
    let fileManager = FileManager.default
    let documentsDirectory = try! fileManager.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: false
    )
    let fritzDirectory = documentsDirectory.appendingPathComponent(
      "Fritz/Models",
      isDirectory: true
    )
    return LocalModelManager(fileManager: fileManager, rootURL: fritzDirectory)
  }()
}

// MARK: - Analytics
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SessionManager {

  /// Posts a timing event about a model
  private func time(
    for modelConfig: FritzModelConfiguration,
    event: SessionEvent.EventType,
    startTime: UInt64,
    error: Error?
  ) {
    logger.debug("Tracking Timing Event:", event.rawValue, "model:", modelConfig.identifier)

    var options: RequestOptions = [
      "elapsed_nano_seconds": DispatchTime.now().uptimeNanoseconds - startTime,
      "model_uid": modelConfig.identifier,
      "model_version": modelConfig.version,
    ]

    if let error = error {
      options["error"] = error.toJSON()
    }

    trackEvent(.init(type: event, data: options))
  }
}

// MARK: - Read Model
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SessionManager {

  /// Reads a model from the fritz api
  /// If the model is not cached, this method returns nil as there is no backend.
  /// - Parameters:
  ///   - modelConfig: Model configuration
  ///   - checkCache: If true will check cache for recent active model response (if no pinned version specified)
  ///   - completionHandler: Completion handler to execute on server response.
  func readServerModel(
    _ modelConfig: FritzModelConfiguration,
    checkCache: Bool = true,
    _ completionHandler: @escaping (ActiveServerModel?, Error?) -> Void
  ) {
    let serverModelRefreshInterval = session.settings.activeModelRefreshInterval
    if checkCache == true,
      let cachedModel = ServerModelCache.shared[modelConfig.identifier],
      Date() < cachedModel.updatedAt.addingTimeInterval(serverModelRefreshInterval)
    {
      let cacheMessage = "[\(cachedModel.model.id) - \(cachedModel.model.version)]:  Server model last updated at \(cachedModel.updatedAt), returning existing info"

      // Only return cached version if pinned version == cached model version
      // or no pinned version exists.
      // If pinned version exists but does not match version of cached model,
      // do not use cached version.
      if let pinnedVersion = modelConfig.pinnedVersion {
        if pinnedVersion == cachedModel.model.version {
          logger.info(cacheMessage)
          completionHandler(cachedModel.model, nil)
          return
        }
      } else {
        logger.info(cacheMessage)
        completionHandler(cachedModel.model, nil)
        return
      }
    }
    guard session.settings.apiRequestsEnabled else {
      logger.debug("Api Requests Disabled - Skipping Read Model")
      return completionHandler(nil, SessionManagerError.disabled)
    }
  }
}

// MARK: - Read Model
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SessionManager {

  /// Reads a model from the fritz api
  /// Note: This method returns nil as there is no longer a backend.
  func readActiveModelsForTags(
    tags: [String],
    _ completionHandler: @escaping (ActiveServerModels?, Error?) -> Void
  ) {
    guard session.settings.apiRequestsEnabled else {
      logger.debug("Api Requests Disabled - Skipping Read Model")
      return completionHandler(nil, SessionManagerError.disabled)
    }
  }
}

// MARK: - Download / Compile Model
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SessionManager {

  /// Downloads and compiles a model
  /// Note: This method does does nothing as there is no longer a backend.
  func downloadAndCompileModel(
    for modelConfig: FritzModelConfiguration,
    serverModelInfo: ActiveServerModel,
    completionHandler: @escaping (LocalModelInfo?, Error?) -> Void
  ) {
    guard session.settings.apiRequestsEnabled else {
      logger.debug("Api Requests Disabled - Skipping Download Model")
      return completionHandler(nil, SessionManagerError.disabled)
    }
  }

  /// Compiles a new model for a given model id
  func compileModel(for modelConfig: FritzModelConfiguration, at temporaryURL: URL) throws -> URL {
    logger.info("Compiling Model:", modelConfig.identifier, modelConfig.version)
    let info = SessionManager.localModelManager.createInfo(modelConfig)

    let startTime = DispatchTime.now().uptimeNanoseconds
    do {
      try SessionManager.localModelManager.createInfoDirectory(info)
      let localURL = temporaryURL

      let url = try MLModel.compileModel(at: localURL)
      try fileManager.removeItem(at: localURL)
      let compiledModelURL = try SessionManager.localModelManager.moveCompiledModel(info, at: url)

      time(for: modelConfig, event: .modelCompileCompleted, startTime: startTime, error: nil)
      return compiledModelURL
    } catch {
      time(for: modelConfig, event: .modelCompileFailed, startTime: startTime, error: error)
      FritzError.post(
        session: session,
        modelIdentifier: modelConfig.identifier,
        code: .modelCompilation,
        error: error
      )
      throw error
    }
  }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SessionManager {
  /// Note: This method does does nothing as is no longer a backend.
  public func download(
    _ modelConfig: FritzModelConfiguration,
    completionHandler: @escaping (URL?) -> Void
  ) {
    logger.debug("Api Requests Disabled - Skipping Download")
  }

  internal func download(
    _ modelConfig: FritzModelConfiguration,
    completionHandler: @escaping (LocalModelInfo?, Error?) -> Void
  ) {
    let localInfo = SessionManager.localModelManager.getLocalInfo(modelConfig)
    guard localInfo == nil else {
      logger.debug("Model \(modelConfig.identifier) already downloaded")
      completionHandler(localInfo!, nil)
      return
    }

    logger.debug("Downloading Server model: \(modelConfig.identifier)")
    readServerModel(modelConfig) { serverModel, error in
      guard let activeServerModel = serverModel else {
        completionHandler(nil, error)
        return
      }
      self.logger.debug("Fetched active model version \(activeServerModel.version)")

      let newConfig = FritzModelConfiguration(
        from: activeServerModel,
        modelConfig: modelConfig
      )
      self.downloadAndCompileModel(
        for: newConfig,
        serverModelInfo: activeServerModel,
        completionHandler: completionHandler
      )
    }
  }
}
