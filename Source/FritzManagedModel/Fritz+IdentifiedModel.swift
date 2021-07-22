//
//  FritzIdentifiedModel.swift
//  Fritz
//
//  Created by Andrew Barba on 9/22/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import FritzCore

/// Manages an MLModel instance
@objc(FritzReadModelProvider)
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public protocol ReadModelProvider {

  /// A read model
  var model: MLModel { get }

  /// The url of the compiled model url in the bundle.
  @objc(urlOfModelInThisBundle)
  optional static var urlOfModelInThisBundle: URL { get }
}

// MARK: - Base

/// This is the main entry point to exposing Fritz functionality on your Xcode-generated model classes.
/// 
/// - SeeAlso:
/// `SwiftIdentifiedModel`
/// `ObjcIdentifiedModel`
/// 
/// - Note: You should not conform your generated class to this protocol directly, instead conform to either `SwiftIdentifiedModel` when using Swift, or `ObjcIdentifiedModel` when using Objective-C.
@objc(FritzBaseIdentifiedModel)
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public protocol BaseIdentifiedModel: ReadModelProvider {

  /**
   The Fritz model identifier that matches this class.
   
   - Note: You should copy this identifier from the Fritz dashboard
   */
  @objc(fritzModelIdentifier)
  static var modelIdentifier: String { get }

  /**
   This is the version of the model that is packaged with your application at submission time.
   
   - Note: As you upload newer versions of your model to the Fritz dashboard, clients will download those versions and begin using them automatically. This version is specifically for tracking the version that is installed on the device when they first download the app from the App Store. In order to maintain accurate tracking you should update this version number when you package a later version of a model into your app and resubmit to the App Store with that later version.
   */
  @objc(fritzPackagedModelVersion)
  static var packagedModelVersion: Int { get }

  /**
   The specific version of the model requested by the SDK.

   - Note: Specifying a pinned version will override usage of the the packaged version, granting the SDK flexibility in regards to downloading different models.
   */
  @objc(fritzPinnedModelVersion)
  optional static var pinnedModelVersion: Int { get }

  /**
   Signifies whether or not the model is encrypted.
   */
  @objc(fritzEncryptionSeed)
  optional static var encryptionSeed: [UInt8] { get }

  /**
   A Fritz configuration encapsualtes your App Token and the Environment in which to send all Fritz-related requests.
   */
  @objc(fritzConfiguration)
  optional static var configuration: Configuration { get }

  /**
   Specifies whether or not phone must be connected to wifi for model downloads to happen. If not set, defaults to false, models will download over cell connections.
   */
  @objc(fritzWifiRequiredForDownload)
  optional static var wifiRequiredForDownload: Bool { get }

}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension BaseIdentifiedModel {

  /// Used internally to always have a non-null configuration
  /// Note: This is needed because Objective-C does not support protocol defaults
  internal static var resolvedConfiguration: Configuration {
    return configuration ?? FritzCore.configuration
  }

  /// Identifier for this instance, proxy from the class identifier
  public var identifier: String {
    return type(of: self).modelIdentifier
  }

  /// If model is encrypted or not.
  public var encryptionSeed: [UInt8]? {
    return type(of: self).encryptionSeed
  }

  /// Configuration for this instance, proxy from the class configuration
  public var configuration: Configuration {
    return type(of: self).configuration ?? FritzCore.configuration
  }

  /// Packaged version for this class, proxy from the class version
  public var packagedModelVersion: Int {
    return type(of: self).packagedModelVersion
  }

  /// Pinned version for this class, proxy from the class version
  public var pinnedModelVersion: Int? {
    return type(of: self).pinnedModelVersion
  }

  /// isWifiRequiredForDownload for this class, proxy from the class version
  public var wifiRequiredForDownload: Bool {
    return type(of: self).wifiRequiredForDownload ?? false
  }
}

// MARK: - Swift

/// Conform your Xcode-generated Swift class to this protocol to expose Fritz functionality
/// 
/// - SeeAlso: `BaseIdentifiedModel`
@objc(FritzSwiftIdentifiedModel)
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public protocol SwiftIdentifiedModel: BaseIdentifiedModel {
  
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SwiftIdentifiedModel {
  
  /**
   Injects a Fritz managed model into this instance allowing the SDK to instrument model predications.
   
   - Returns: The same instance that this method was called.
   */
  @available(*, deprecated, message: "Use fritzModel() instead to create a FritzMLModel.")
  public func fritz() -> Self {
    return self
  }
  
  /**
    Create a FritzMLModel from the MLModel stored within the class.
   
    - Note: Previous versions of the Fritz SDK injected FritzMLModels into the Swift classes generated by Xcode for Core ML models. This injection method can no longer be used as of Xcode 12 and iOS 14. Instead, this method constructs a FritzManagedModel and loads the appropriate Core ML model into a FritzMLModel. If you are using the Fritz SDK for analytics and reporting on custom Core ML models outside of FritzVisionPredictors, note that the FritzMLModel returned by this function does not have some convinience methods that were available on the generated Swift classes. If you are using a model with the built in FritzVisionPredictor classes, you should not need to make any changes.
   */
  public func fritzModel() -> FritzMLModel {
    let managedModel = FritzManagedModel(identifiedModel: self)
    managedModel.updateModelIfNeeded { _, _ in }
    return managedModel.loadModel(identifiedModel: self)
  }

  /**
   Manually check for an OTA model update
   */
  public func updateIfNeeded(completionHandler: @escaping (Bool, Error?) -> Void) {
    let managedModel = FritzManagedModel(identifiedModel: self)
    managedModel.updateModelIfNeeded(completionHandler: completionHandler)
  }

  /**
   Manually check for an OTA model update
   */
  public static func updateIfNeeded(completionHandler: @escaping (Bool, Error?) -> Void) {
    FritzCore.resetSessionIdentifierIfNeeded()
    let config = FritzModelConfiguration(
      identifier: Self.modelIdentifier,
      version: Self.packagedModelVersion
    )
    let managedModel = FritzManagedModel(
      modelConfig: config,
      sessionManager: Self.resolvedConfiguration.sessionManager
    )
    managedModel.updateModelIfNeeded(completionHandler: completionHandler)
  }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SwiftIdentifiedModel {

  /// Downloads active model for IdentifiedModel.
  ///
  /// - Parameter completionHandler: Completion with Optional URL of compiled model. The URL is returned so you can instantiate the model with the generated class from Core ML.
  public static func download(completionHandler: @escaping (URL?) -> Void) {
    var modelConfig: FritzModelConfiguration
    if let isPinned = self.pinnedModelVersion {
      modelConfig
        = FritzModelConfiguration(
          identifier: self.modelIdentifier,
          version: self.packagedModelVersion,
          pinnedVersion: isPinned
        )
    } else {
      modelConfig
        = FritzModelConfiguration(
          identifier: self.modelIdentifier,
          version: self.packagedModelVersion
        )
    }

    let managedModel = modelConfig.buildManagedModel()
    managedModel.downloadAndFetchModel { model, error in
      guard let mlmodel = model else {
        completionHandler(nil)
        return
      }
      guard let localInfo = SessionManager.localModelManager.getLocalInfo(mlmodel.activeModelConfig)
      else {
        completionHandler(nil)
        return
      }

      completionHandler(SessionManager.localModelManager.compiledModelURL(localInfo))
    }
  }
}

// MARK: - Objective-C

/// Conform your Xcode-generated Objective-C class to this protocol to expose Fritz functionality
/// 
/// - SeeAlso: `BaseIdentifiedModel`
@available(iOS 11.0, *)
@available(iOSApplicationExtension 11.0, *)
@objc(FritzObjcIdentifiedModel)
public protocol ObjcIdentifiedModel: BaseIdentifiedModel {}

/// - Note: In order to expose a Swift extension to Objective-C the extension *must* be mode on a concrete class and not a protocol. Ideally this extension would be made on `ObjcIdentifiedModel` but this is not possible as of Swift 4 and Xcode 9.
/// 
/// - SeeAlso: `ObjcIdentifiedModel`
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension NSObject {

  /**
   Injects a Fritz managed model into this instance allowing the SDK to instrument model predications.
   
   - Returns: The same instance that this method was called.
   
   - Warning: When Xcode generates a Swift class based on a MLModel file it provides a read-write model property that allows the SDK to safely overwrite the model with a Fritz managed model. When using Objective-C, Xcode generates a class with a readonly model property which forces us to use `setValue:forKey:` instead of a type-safe setter. It's crucial to test your apps on future beta versions of iOS as Apple could change the underlying implementation of the model property causing this method to crash. If this is the case, we will have updated SDKs ready for those newer versions.
   
   - Note: This method will have no affect on any object that does not conform to `ObjcIdentifiedModel`.
   */
  @objc(fritz)
  public func fritz() -> Self {
    if let instance = self as? ObjcIdentifiedModel {
      let managedModel = FritzManagedModel(identifiedModel: instance)
      managedModel.updateModelIfNeeded { _, _ in }
      let fritzMLModel = managedModel.loadModel(identifiedModel: instance)
      setValue(fritzMLModel, forKey: "model")
    }
    return self
  }

  /**
   Manually check for an OTA model update
   */
  @objc(updateIfNeeded)
  public func updateIfNeeded() {
    type(of: self).updateIfNeeded()
  }

  /**
   Manually check for an OTA model update
   */
  @objc(updateIfNeeded)
  public static func updateIfNeeded() {
    guard let modelType = self as? ObjcIdentifiedModel.Type else { return }
    FritzCore.resetSessionIdentifierIfNeeded()
    let modelDescription = FritzModelConfiguration(
      identifier: modelType.modelIdentifier,
      version: modelType.packagedModelVersion
    )
    let managedModel = FritzManagedModel(
      modelConfig: modelDescription,
      sessionManager: modelType.resolvedConfiguration.sessionManager
    )
    managedModel.updateModelIfNeeded { _, _ in }
  }
}
