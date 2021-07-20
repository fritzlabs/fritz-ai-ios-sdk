//
//  Errors.swift
//  Fritz
//
//  Created by Andrew Barba on 11/1/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

/// The type of error encountered
@objc(FritzErrorCode)
public enum ErrorCode: Int {
  case modelCompilation
  case modelDecryption
  case modelDownload
  case sessionDisabled
  case modelInitialization
}

/// Class representing a Fritz-related error
/// 
/// - Note: You subscribe to a notification to be notified anytime an error is encountered in the SDK.
/// 
/// - SeeAlso: `Notification.Name.fritzError`
@objc(FritzError)
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public final class FritzError: NSError {

  /// Session error ocurred in
  public let session: Session

  /// Model identifier related to error
  public let modelIdentifier: String

  /// Actual thrown error
  public let error: Error

  /// Posts a Fritz error to the default notification center
  internal static func post(error: FritzError) {
    NotificationCenter.default.post(name: .fritzError, object: error)
  }

  /// Posts a Fritz error to the default notification center
  public static func post(session: Session, modelIdentifier: String, code: ErrorCode, error: Error)
  {
    let error = FritzError(
      session: session,
      modelIdentifier: modelIdentifier,
      code: code,
      error: error
    )
    post(error: error)
  }

  /// Create an internal Fritz error
  public init(session: Session, modelIdentifier: String, code: ErrorCode, error: Error) {
    self.session = session
    self.modelIdentifier = modelIdentifier
    self.error = error
    super.init(domain: "Fritz-\(session.apiKey)", code: code.rawValue, userInfo: nil)
  }

  /// Do not create an instance of this class directly
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - JSON

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension Error {

  /// Converts an error to json to send over the network
  public func toJSON() -> [String: Any] {
    switch self {
    case let error as FritzError:
      return [
        "domain": error.domain,
        "code": error.code,
        "description": error.localizedDescription,
        "sub_error": error.error.toJSON(),
      ]
    case let error as NSError:
      return [
        "domain": error.domain,
        "code": error.code,
        "description": error.localizedDescription,
      ]
    default:
      return [
        "domain": "Unknown",
        "code": -1,
        "description": self.localizedDescription,
      ]
    }
  }
}
