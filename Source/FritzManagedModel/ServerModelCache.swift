//
//  FritzModelTagManager.swift
//  FritzManagedModel
//
//  Created by Christopher Kelly on 1/21/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

struct CachedModel: Codable {

  let model: ActiveServerModel
  var updatedAt: Date
}

/// Caches the latest model details we know about the server state.
/// It's important to note that this is *not* the same as active
/// models as instantiated in FritzManagedModel.  This keeps
/// the latest information we know about model state (which model is
/// active, model details).
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
internal class ServerModelCache: Codable {

  private enum CodingKeys: String, CodingKey {
    case modelsByID
  }

  private static var _instance: ServerModelCache?

  private var modelsByID: [String: CachedModel]

  private let logger = Logger(name: "ServerModelCache")

  /// Shared ServerModelCache
  static var shared: ServerModelCache {
    if let instance = _instance {
      return instance
    }

    if let newInstance = SessionManager.localModelManager.loadAllModels() {
      _instance = newInstance
    } else {
      _instance = ServerModelCache()
    }
    return _instance!
  }

  subscript(identifier: String) -> CachedModel? {
    return modelsByID[identifier]
  }

  /// List of ActiveServerModel's stored.
  var models: [ActiveServerModel] { return modelsByID.values.map { $0.model } }

  init() {
    modelsByID = [:]
  }

  /// Clear static cache.
  static func clear() throws {
    try SessionManager.localModelManager.removeServerModelCache()
    _instance = nil
  }

  func remove(_ modelIdentifier: String) throws {
    modelsByID[modelIdentifier] = nil
    try SessionManager.localModelManager.persistAllModels(self)
  }

  func update(_ activeModels: [ActiveServerModel]) {
    for activeModel in activeModels {
      modelsByID[activeModel.id] = CachedModel(model: activeModel, updatedAt: Date())
    }

    do {
      try SessionManager.localModelManager.persistAllModels(self)
    } catch {
      logger.error("Failed to persist models after updating ActiveServerCache")
    }
  }
}
