//
//  ModelInfo.swift
//  Fritz
//
//  Created by Andrew Barba on 9/21/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import FritzCore

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public struct ActiveServerModels: Codable, Equatable {
  let versions: [ActiveServerModel]
}

public typealias ModelMetadata = [String: String]

/// Model metadata to represent which model is currently active.
internal struct ActiveServerModel: Codable, Equatable {

  /// ID of this model
  let id: String  // swiftlint:disable:this identifier_name

  /// Model version number
  let version: Int

  /// Src to download this model (if from a downloadable model).
  /// May be better way of doing this with subclasses? Not sure if it's possible to choose
  /// based on if url or not.
  let src: URL?

  /// Model tags.
  let tags: [String]?

  /// Model Metadata set in webapp
  let metadata: ModelMetadata?

  var isOTA: Bool {
    return src != nil
  }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
@objc(FritzModelConfiguration)
public class FritzModelConfiguration: NSObject, Codable {

  // CodingKeys not storing
  private enum CodingKeys: String, CodingKey {
    case identifier = "id"
    case version
    case pinnedVersion
    case src
    case _wifiRequiredForModelDownload
    case _metadata = "metadata"
    case _tags = "tags"
  }

  /// The source to download this model
  private let src: URL?

  /// The unique id of this model
  @objc public let identifier: String

  /// The latest version of this model
  @objc public let version: Int

  /// The targeted version of this model, if any
  public var pinnedVersion: Int?

  /// Tags for this model, if any
  private var _tags: [String]?

  /// Tags data set in webapp.  Pulls from most recently updated active server response if one exists.
  @objc public var tags: [String]? {
    get {
      // Return cached data if it exists.  This way, we're always using the latest
      // available data from the server for this ID.  I think this is an _okay_ way of
      // doing it, but it's definitely hacky.  In the future, it might be better to make
      // sure there is a single model config that is easier to update? Not sure just yet.
      if let cachedModel = ServerModelCache.shared[identifier] {
        return cachedModel.model.tags
      }
      return _tags
    }
    set {
      _tags = newValue
    }
  }

  private var _wifiRequiredForModelDownload: Bool?

  private var _metadata: ModelMetadata?

  /// Model Metadata set in webapp. Uses cached server model info if it exists.
  @objc public var metadata: ModelMetadata? {
    get {
      // Return cached data if it exists.  This way, we're always using the latest
      // available data from the server for this ID.  I think this is an _okay_ way of
      // doing it, but it's definitely hacky.  In the future, it might be better to make
      // sure there is a single model config that is easier to update? Not sure just yet.
      if let cachedModel = ServerModelCache.shared[identifier] {
        return cachedModel.model.metadata
      }
      return _metadata
    }
    set {
      _metadata = newValue
    }
  }

  /// Model downloads will only happen
  @objc public var wifiRequiredForModelDownload: Bool {
    get {
      return _wifiRequiredForModelDownload ?? false
    }
    set {
      _wifiRequiredForModelDownload = newValue
    }
  }

  private var _cpuAndGPUOnly: Bool?

  /// Whether or not this model should use CPU and GPU only (not using the ANE).
  @objc public var cpuAndGPUOnly: Bool {
    return _cpuAndGPUOnly ?? false
  }

  internal var encryptionSeed: [UInt8]?

  @objc public var isOTA: Bool {
    return src != nil
  }

  override public var description: String {
    return
      "\(type(of: self))(id: \(identifier), version: \(version), tags: src: \(String(describing: tags))src: \(String(describing: src)))"
  }

  @objc(
    initWithIdentifier:
    version:
    encryptionSeed:
    src:
    tags:
    isWifiRequiredForDownloads:
    metadata:
    cpuAndGPUOnly:
  )
  public init(
    identifier: String,
    version: Int,
    encryptionSeed: [UInt8]?,
    src: URL?,
    tags: [String]?,
    wifiRequiredForModelDownload: Bool,
    metadata: ModelMetadata?,
    cpuAndGPUOnly: Bool
  ) {
    self.version = version
    self.pinnedVersion = nil
    self.identifier = identifier
    self.encryptionSeed = encryptionSeed
    self.src = src
    self._tags = tags
    self._wifiRequiredForModelDownload = wifiRequiredForModelDownload
    self._metadata = metadata
  }

  @objc(
    initWithIdentifier:
    version:
    pinnedVersion:
    encryptionSeed:
    src:
    tags:
    isWifiRequiredForDownloads:
    metadata:
    cpuAndGPUOnly:
  )
  public init(
    identifier: String,
    version: Int,
    pinnedVersion: Int,
    encryptionSeed: [UInt8]?,
    src: URL?,
    tags: [String]?,
    wifiRequiredForModelDownload: Bool,
    metadata: ModelMetadata?,
    cpuAndGPUOnly: Bool
  ) {
    self.version = version
    self.pinnedVersion = pinnedVersion
    self.identifier = identifier
    self.encryptionSeed = encryptionSeed
    self.src = src
    self._tags = tags
    self._wifiRequiredForModelDownload = wifiRequiredForModelDownload
    self._metadata = metadata
  }

  @objc(initWithIdentifier:version:cpuAndGPUOnly:)
  public convenience init(identifier: String, version: Int, cpuAndGPUOnly: Bool = false) {
    self.init(
      identifier: identifier,
      version: version,
      encryptionSeed: nil,
      src: nil,
      tags: nil,
      wifiRequiredForModelDownload: false,
      metadata: nil,
      cpuAndGPUOnly: cpuAndGPUOnly
    )
  }

  @objc(initWithIdentifier:version:pinnedVersion:cpuAndGPUOnly:)
  public convenience init(
    identifier: String,
    version: Int,
    pinnedVersion: Int,
    cpuAndGPUOnly: Bool = false
  ) {
    self.init(
      identifier: identifier,
      version: version,
      pinnedVersion: pinnedVersion,
      encryptionSeed: nil,
      src: nil,
      tags: nil,
      wifiRequiredForModelDownload: false,
      metadata: nil,
      cpuAndGPUOnly: cpuAndGPUOnly
    )
  }

  @objc(initFromIdentifiedModel:)
  public convenience init(from identifiedModel: BaseIdentifiedModel) {
    if let isPinned = identifiedModel.pinnedModelVersion {
      self.init(
        identifier: identifiedModel.identifier,
        version: identifiedModel.packagedModelVersion,
        pinnedVersion: isPinned,
        encryptionSeed: type(of: identifiedModel).encryptionSeed,
        src: nil,
        tags: nil,
        wifiRequiredForModelDownload: identifiedModel.wifiRequiredForDownload,
        metadata: nil,
        cpuAndGPUOnly: false
      )
    } else {
      self.init(
        identifier: identifiedModel.identifier,
        version: identifiedModel.packagedModelVersion,
        encryptionSeed: type(of: identifiedModel).encryptionSeed,
        src: nil,
        tags: nil,
        wifiRequiredForModelDownload: identifiedModel.wifiRequiredForDownload,
        metadata: nil,
        cpuAndGPUOnly: false
      )
    }
  }

  @objc(initFromIdentifiedModelType:)
  public convenience init(from identifiedModelType: BaseIdentifiedModel.Type) {
    if let isPinned = identifiedModelType.pinnedModelVersion {
      self.init(
        identifier: identifiedModelType.modelIdentifier,
        version: identifiedModelType.packagedModelVersion,
        pinnedVersion: isPinned,
        encryptionSeed: identifiedModelType.encryptionSeed,
        src: nil,
        tags: nil,
        wifiRequiredForModelDownload: identifiedModelType.wifiRequiredForDownload ?? false,
        metadata: nil,
        cpuAndGPUOnly: false
      )
    } else {
      self.init(
        identifier: identifiedModelType.modelIdentifier,
        version: identifiedModelType.packagedModelVersion,
        encryptionSeed: identifiedModelType.encryptionSeed,
        src: nil,
        tags: nil,
        wifiRequiredForModelDownload: identifiedModelType.wifiRequiredForDownload ?? false,
        metadata: nil,
        cpuAndGPUOnly: false
      )
    }
  }

  internal convenience init(
    from localInfo: LocalModelInfo,
    activeModelConfig: FritzModelConfiguration
  ) {
    self.init(
      identifier: localInfo.id,
      version: localInfo.version,
      encryptionSeed: activeModelConfig.encryptionSeed,
      src: localInfo.compiledModelURL,
      tags: activeModelConfig.tags,
      wifiRequiredForModelDownload: false,
      metadata: activeModelConfig.metadata,
      cpuAndGPUOnly: activeModelConfig.cpuAndGPUOnly
    )
  }

  internal convenience init(
    from activeServerInfo: ActiveServerModel,
    modelConfig: FritzModelConfiguration
  ) {
    self.init(
      identifier: activeServerInfo.id,
      version: activeServerInfo.version,
      encryptionSeed: modelConfig.encryptionSeed,
      src: activeServerInfo.src,
      tags: activeServerInfo.tags,
      wifiRequiredForModelDownload: modelConfig.wifiRequiredForModelDownload,
      metadata: activeServerInfo.metadata,
      cpuAndGPUOnly: modelConfig.cpuAndGPUOnly
    )
  }

  @objc(isEqual:)
  override public func isEqual(_ object: Any?) -> Bool {
    if let object = object as? FritzModelConfiguration {
      let areEqual = identifier == object.identifier && version == object.version
        && src == object.src && encryptionSeed == object.encryptionSeed
        && wifiRequiredForModelDownload == object.wifiRequiredForModelDownload
        && metadata == object.metadata && cpuAndGPUOnly == object.cpuAndGPUOnly

      return areEqual
    }
    return false
  }

  override public var hash: Int {
    return identifier.hash ^ version.hashValue ^ (src?.hashValue ?? 1) ^ encryptionSeed.hashValue
      ^ wifiRequiredForModelDownload.hashValue
  }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
func == (lhs: FritzModelConfiguration, rhs: FritzModelConfiguration) -> Bool {
  return lhs.isEqual(rhs)
}

/// Model metadata about a model saved on disk.
///
/// When loading a specific ActiveModelInfo configuration, this is used
/// to determine what steps can be done to load ActiveModelInnfo object.
internal struct LocalModelInfo: Codable {

  /// ID of this model
  let id: String  // swiftlint:disable:this identifier_name

  /// Model version number
  let version: Int

  /// Compiled model url.
  fileprivate let compiledModelURL: URL?

  /// Was this model downloaded OTA
  let isOTA: Bool

  /// Has this model been compiled and stored locally?
  var isModelCompiled: Bool {
    return compiledModelURL != nil
  }

  /// Marks the info as compiled
  func compiled(to url: URL) -> LocalModelInfo {
    let info = LocalModelInfo(id: id, version: version, compiledModelURL: url, isOTA: isOTA)
    return info
  }

  public init(id: String, version: Int, compiledModelURL: URL?, isOTA: Bool) {
    self.id = id
    self.version = version
    self.compiledModelURL = compiledModelURL
    self.isOTA = isOTA
  }
}

extension LocalModelInfo: Equatable {}

func == (lhs: LocalModelInfo, rhs: LocalModelInfo) -> Bool {
  let areEqual = lhs.id == rhs.id && lhs.version == rhs.version
    && lhs.compiledModelURL == rhs.compiledModelURL && lhs.isOTA == rhs.isOTA

  return areEqual
}

@available(iOS 11.0, *)
extension FritzModelConfiguration {

  /// Create managed model from current FritzModelConfiguration
  @objc(buildManagedModel)
  public func buildManagedModel() -> FritzManagedModel {
    return FritzManagedModel(modelConfig: self)
  }
}
