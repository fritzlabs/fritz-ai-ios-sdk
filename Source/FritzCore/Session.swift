//
//  Session.swift
//  Fritz
//
//  Created by Andrew Barba on 9/19/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

/// Encapsualtes your App Token and the Environment in which to send all Fritz-related requests.
/// 
/// - Note: By default the SDK will read your App Token from the `FritzToken` line in your apps Info.plist. However, by providing a `Session` when conforming to `BaseIdentifiedModel` you have the ability to use models in your app that are from different Fritz accounts. This is useful if you are an SDK author and want to include Fritz as a dependency in your SDK without affecting the end-develoeprs ability to also use Fritz with their App Token.
@objc(FritzSession)
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public final class Session: NSObject {

  public struct Info: Decodable {
    public let apiKey: String
    public let apiUrl: String
    public let namespace: String
  }

  /// Default session to use throughout SDK
  @objc(defaultSession)
  public static let `default`: Session = {
    guard
      let url = Bundle.main.url(forResource: "Fritz-Info", withExtension: "plist"),
      let data = try? Data(contentsOf: url),
      let info = try? PropertyListDecoder().decode(Info.self, from: data)
    else { fatalError("Please download the Fritz-Info.plist") }
    return Session(apiKey: info.apiKey, apiUrl: info.apiUrl, namespace: info.namespace)
  }()

  /// App token sent on all requests
  public let apiKey: String

  /// Api to connect to
  public let apiUrl: String

  /// Namespace for local storage of Fritz files
  public let namespace: String

  /// Current settings for this session
  public var settings: SessionSettings {
    return .settings(for: self)
  }

  /// Create a session
  @objc(initWithAppToken:apiUrl:namespace:)
  public init(apiKey: String, apiUrl: String, namespace: String) {
    self.apiKey = apiKey
    self.apiUrl = apiUrl
    self.namespace = namespace
    super.init()
  }

  /// Create a session
  @objc(initWithAppToken:)
  public convenience init(apiKey: String) {
    self.init(apiKey: apiKey, apiUrl: "http://localhost:port/sdk/v1", namespace: "Production")
  }
}
