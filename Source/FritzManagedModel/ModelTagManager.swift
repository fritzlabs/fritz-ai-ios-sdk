//
//  ManagedModelTagManager.swift
//  FritzManagedModel
//
//  Created by Christopher Kelly on 1/22/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
  fileprivate func contains(array: [Element]) -> Bool {
    for item in array {
      if !self.contains(item) { return false }
    }
    return true
  }
}

/// Manages interacting with models using tags created in the webapp.
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
@objc(ModelTagManager)
public class ModelTagManager: NSObject {

  /// Tags applied to models to query for.
  @objc public let tags: [String]

  internal let sessionManager: SessionManager

  @objc(initWithTags:sessionManager:)
  public init(tags: [String], sessionManager: SessionManager? = nil) {
    self.tags = tags
    self.sessionManager = sessionManager ?? FritzCore.configuration.sessionManager
    super.init()
  }

  /// Gets managed models matching tags, pulling from data already queries from API.
  ///
  /// Does not query the API, only checks model data stored locally. To update tags with latest known data,
  /// use `fetchModelsForTags`.
  ///
  /// - Parameters:
  ///   - wifiRequiredForModelDownload: Optional value to require wifi when downloading models loaded from tags.
  /// - Returns: List of FritzManagedModel matching tags.
  @objc(getModelsForTagsWithWifiRequired:)
  public func getManagedModelsForTags(
    wifiRequiredForModelDownload: Bool = false
  ) -> [FritzManagedModel] {
    // This is kind of a weird place to convert to a model config.
    // I may want to change the cache back to just store Fritz Model Configurations.
    // I did like that it's more explicit that it's actively caching just the
    // Active Server Model response.
    return ServerModelCache.shared.models.filter {
      ($0.tags ?? []).contains(array: tags)
    }.map {
      return FritzModelConfiguration(
        identifier: $0.id,
        version: $0.version,
        encryptionSeed: nil,
        src: $0.src,
        tags: $0.tags,
        wifiRequiredForModelDownload: wifiRequiredForModelDownload,
        metadata: $0.metadata,
        cpuAndGPUOnly: false
      )
    }.map {
      FritzManagedModel(modelConfig: $0)
    }
  }

  /// Fetch FritzManagedModels from Fritz API that match tags. If the request fails for any reason, it
  /// will query local store and return existing models that match models.
  ///
  /// - Parameters:
  ///   - wifiRequiredForModelDownload: Optional value to require wifi when downloading models loaded from tags.
  ///   - completionHandler: Called after models for tags are loaded.
  @objc(fetchModelsForTagsWithWifiRequired:completionHandler:)
  public func fetchManagedModelsForTags(
    wifiRequiredForModelDownload: Bool = false,
    completionHandler: @escaping ([FritzManagedModel]?, Error?) -> Void
  ) {
    sessionManager.readActiveModelsForTags(tags: tags) { activeModels, error in
      // Returning models whether or not the request succeeded.  If the request did not succeed,
      // will return any existing data we have stored.
      completionHandler(
        self.getManagedModelsForTags(wifiRequiredForModelDownload: wifiRequiredForModelDownload),
        error
      )
    }
  }
}
