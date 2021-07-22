//
//  LocalModelManager.swift
//  Fritz
//
//  Created by Andrew Barba on 5/21/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import FritzCore

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
internal final class LocalModelManager {

  let fileManager: FileManager

  let rootURL: URL

  // MARK: - Init

  init(fileManager: FileManager, rootURL: URL) {
    self.fileManager = fileManager
    self.rootURL = rootURL
  }

  // MARK: - Internal

  private func createRootDirectory() throws {
    try fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true, attributes: nil)
  }

  private func modelDirectory(modelIdentifier: String) -> URL {
    return rootURL.appendingPathComponent(modelIdentifier, isDirectory: true)
  }

  func removeModelDirectory(modelIdentifier: String) throws {
    try FileManager.default.removeItem(at: modelDirectory(modelIdentifier: modelIdentifier))
  }

  private func createModelDirectory(modelIdentifier: String) throws {
    let directory = modelDirectory(modelIdentifier: modelIdentifier)
    try fileManager.createDirectory(
      at: directory,
      withIntermediateDirectories: true,
      attributes: nil
    )
  }

  func compiledModelURL(_ info: LocalModelInfo) -> URL {
    let directory = infoDirectory(modelIdentifier: info.id, version: info.version)
    return directory.appendingPathComponent("model.mlmodelc", isDirectory: true)
  }

  func decryptedModelURL(_ info: LocalModelInfo) -> URL {
    let directory = infoDirectory(modelIdentifier: info.id, version: info.version)
    return directory.appendingPathComponent("model.dec")
  }

  /// Move a compiled model from another location on disk to the proper folder in the document directory.
  func moveCompiledModel(_ info: LocalModelInfo, at url: URL) throws -> URL {
    try createInfoDirectory(info)

    let compiledModelURL = self.compiledModelURL(info)

    if fileManager.fileExists(atPath: compiledModelURL.path) {
      try fileManager.removeItem(at: compiledModelURL)
    }

    try fileManager.moveItem(at: url, to: compiledModelURL)
    return compiledModelURL
  }
}

// MARK: - Stored ActiveModel
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension LocalModelManager {

  private func activeJsonURL(modelIdentifier: String) -> URL {
    let directory = modelDirectory(modelIdentifier: modelIdentifier)
    return directory.appendingPathComponent("active.json")
  }

  func loadActiveModelInfo(_ modelConfig: FritzModelConfiguration) -> FritzModelConfiguration? {
    guard
      let activeData = try? Data(
        contentsOf: activeJsonURL(modelIdentifier: modelConfig.identifier)
      ),
      let activeModelConfig = try? JSONDecoder().decode(
        FritzModelConfiguration.self,
        from: activeData
      )
    else { return nil }

    // The encryption seed is not persisted to disk anywhere.  This is a hacky way of setting the encryption seed when it is loaded so we are able to decrypt models from OTA downloads.
    activeModelConfig.encryptionSeed = modelConfig.encryptionSeed

    return activeModelConfig
  }

  func persistActive(_ activeModelConfig: FritzModelConfiguration) throws {
    try createModelDirectory(modelIdentifier: activeModelConfig.identifier)
    let data = try JSONEncoder().encode(activeModelConfig)
    try data.write(to: activeJsonURL(modelIdentifier: activeModelConfig.identifier))
  }
}

// MARK: - LocalModelInfo
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension LocalModelManager {
  private func infoDirectory(modelIdentifier: String, version: Int) -> URL {
    return modelDirectory(modelIdentifier: modelIdentifier).appendingPathComponent(
      "v\(version)",
      isDirectory: true
    )
  }

  private func infoJsonURL(modelIdentifier: String, version: Int) -> URL {
    let directory = infoDirectory(modelIdentifier: modelIdentifier, version: version)
    return directory.appendingPathComponent("info.json")
  }

  func createInfoDirectory(_ info: LocalModelInfo) throws {
    let directory = infoDirectory(modelIdentifier: info.id, version: info.version)
    try fileManager.createDirectory(
      at: directory,
      withIntermediateDirectories: true,
      attributes: nil
    )
  }

  func loadLocalModelInfo(_ activeModelConfig: FritzModelConfiguration) -> LocalModelInfo? {
    // Grab saved ModelInfo for the currently active model. This should always exist if the active model info response does exist.
    guard
      let infoData = try? Data(
        contentsOf: infoJsonURL(
          modelIdentifier: activeModelConfig.identifier,
          version: activeModelConfig.version
        )
      ),
      let info = try? JSONDecoder().decode(LocalModelInfo.self, from: infoData)
    else {
      // Unable to load ModelInfo for active version file, so default to packaged model.
      return nil
    }
    return info
  }

  func getLocalInfo(_ modelConfig: FritzModelConfiguration) -> LocalModelInfo? {
    // Look for saved active model info response.  If this doesn't exist, it means that we have to use the
    // packaged version. The ActiveModelInfo response is only saved after the model is compiled.
    guard let activeModelConfig = loadActiveModelInfo(modelConfig) else { return nil }

    // Grab saved ModelInfo for the currently active model.  This should always exist if the active model info response does exist.
    guard
      let infoData = try? Data(
        contentsOf: infoJsonURL(
          modelIdentifier: activeModelConfig.identifier,
          version: activeModelConfig.version
        )
      ),
      let info = try? JSONDecoder().decode(LocalModelInfo.self, from: infoData)
    else {
      // Unable to load ModelInfo for active version file, so default to packaged model.
      return nil
    }

    return info
  }

  func getOrCreateLocalInfo(_ modelConfig: FritzModelConfiguration) -> LocalModelInfo {
    guard let info = getLocalInfo(modelConfig) else {
      return createInfo(modelConfig, version: modelConfig.version)
    }
    return info
  }

  func createInfo(
    _ modelConfig: FritzModelConfiguration,
    version: Int? = nil,
    compiledModelURL: URL? = nil,
    isOTA: Bool = false
  ) -> LocalModelInfo {
    let modelIdentifier = modelConfig.identifier
    let version = version ?? modelConfig.version
    let info = LocalModelInfo(
      id: modelIdentifier,
      version: version,
      compiledModelURL: compiledModelURL,
      isOTA: isOTA
    )
    return info
  }

  func persistLocalModelInfo(_ info: LocalModelInfo) throws {
    try createInfoDirectory(info)
    let data = try JSONEncoder().encode(info)
    try data.write(to: infoJsonURL(modelIdentifier: info.id, version: info.version))
  }

  func removeLocalModelInfo(_ info: LocalModelInfo) throws {
    let url = infoJsonURL(modelIdentifier: info.id, version: info.version)
    try fileManager.removeItem(at: url)
  }
}

// MARK: - Stored ServerModelCache
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension LocalModelManager {

  private func allModelsURL() -> URL {
    let directory = rootURL
    return directory.appendingPathComponent("all_server_models.json")
  }

  func loadAllModels() -> ServerModelCache? {
    guard
      let activeData = try? Data(contentsOf: allModelsURL()),
      let allModels = try? JSONDecoder().decode(ServerModelCache.self, from: activeData)
    else { return nil }

    return allModels
  }

  func persistAllModels(_ allModels: ServerModelCache) throws {
    try createRootDirectory()
    let data = try JSONEncoder().encode(allModels)
    try data.write(to: allModelsURL())
  }

  func removeServerModelCache() throws {
    try fileManager.removeItem(at: allModelsURL())
  }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension LocalModelManager {
  private func modelOutputURL(_ name: String) -> URL {
    let directory = rootURL
    return directory.appendingPathComponent("\(name)_\(Int(Date().timeIntervalSince1970)).json")
  }

  func writeModelOutput(name: String, data: Data) throws {
    try createRootDirectory()
    let path = modelOutputURL(name)
    try data.write(to: path)
    NSLog("Model Debug Output: \(path)")
  }
}
