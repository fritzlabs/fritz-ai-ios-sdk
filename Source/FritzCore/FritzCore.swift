//
//  FritzCore.swift
//  FritzCore
//
//  Created by Christopher Kelly on 6/8/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

/// Key to reference instance identifier
private let instanceIdentifierKey = "com.fritz.sdk.instance-identifier"

/// Key to reference session identifier
private let sessionIdentifierKey = "com.fritz.sdk.session-identifier"

/// Key to reference session identifier reset date
private let sessionIdentifierDateKey = "com.fritz.sdk.session-identifier-date"

/// Number of seconds of inactivity before expiring the session, default 5 minutes
private let sessionIdentifierExpirationTime: TimeInterval = 60 * 5

@objc(FritzCore)
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class FritzCore: NSObject {

  private static var _configuration: Configuration?
  private static var _orientationManager: DeviceOrientationManager?

  /// Shared configuration
  @objc(configuration)
  public static var configuration: Configuration {
    guard let configuration = _configuration else {
      fatalError(
        """
        Must call FritzCore.configure() in AppDelegate.didFinishLaunchingWithOptions().

        If you are seeing this error and have called FritzCore.configure() in your AppDelegate,
        your model may be loaded before the AppDelegate is called. This can happen if the ViewController
        is loaded from the Storyboard and is the Initial View Controller for the app.

        Try either loading the model in viewDidLoad, or making the model property a lazy variable.

        For more information see https://docs.fritz.ai/get-started.html#ios
        """
      )
    }
    return configuration
  }

  /// Shared configuration
  @objc(orientationManager)
  public static var orientationManager: DeviceOrientationManager {
    guard let orientationManager = _orientationManager else {
      fatalError(
        """
        Must call FritzCore.configure() in AppDelegate.didFinishLaunchingWithOptions().

        If you are seeing this error and have called FritzCore.configure() in your AppDelegate,
        your model may be loaded before the AppDelegate is called. This can happen if the ViewController
        is loaded from the Storyboard and is the Initial View Controller for the app.

        Try either loading the model in viewDidLoad, or making the model property a lazy variable.

        For more information see https://docs.fritz.ai/get-started.html#ios
        """
      )
    }
    return orientationManager
  }

  /// Configure the Fritz SDK
  @objc(configure)
  public static func configure() {
    self._configuration = .default
    self._orientationManager = DeviceOrientationManager()
  }

  /// Configure the Fritz SDK with a custom configuration
  @objc(configureWith:)
  public static func configure(with configuration: Configuration) {
    self._configuration = configuration
    self._orientationManager = DeviceOrientationManager()
  }

  /// Determines if the Fritz SDK is successfully configured
  @objc(isConfigured)
  public static func isConfigured() -> Bool {
    guard let _ = _configuration else {
      return false
    }
    return true
  }

  /**
   Enables Fritz SDK logging

   - Parameter level:
   -- 0: Debug logging
   -- 1: Info logging
   -- 2: Warn logging
   -- 3: Error logging
   -- 4: Disable logging
   */
  @objc(setLogLevel:)
  public static func setLogLevel(_ level: LogLevel) {
    LogLevel.shared = level
  }
}

// MARK: - Instance Identifier

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension FritzCore {

  /// Instance identifier, persisted to defaults
  public static let instanceIdentifier: String = {
    guard let identifier = UserDefaults.standard.string(forKey: instanceIdentifierKey) else {
      let newIdentifier = UUID().uuidString
      UserDefaults.standard.set(newIdentifier, forKey: instanceIdentifierKey)
      return newIdentifier
    }
    return identifier
  }()
}

// MARK: - Session Identifier

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension FritzCore {

  /// Session identifier, persisted to defaults
  public static var sessionIdentifier: String {
    return storedSessionIdentifier ?? resetSessionIdentifierIfNeeded()
  }

  /// Extends the lifetime of session identifier
  public static func extendSessionIdentifier() {
    storedSessionIdentifierDate = Date()
  }

  /// Resets the session identifier if last access was more than the default expiration interval
  /// Returns the current session identifier
  @discardableResult
  public static func resetSessionIdentifierIfNeeded() -> String {
    guard let identifier = storedSessionIdentifier, isSessionIdentifierValid else {
      let newIdentifier = UUID().uuidString
      storedSessionIdentifier = newIdentifier
      storedSessionIdentifierDate = Date()
      return newIdentifier
    }
    return identifier
  }

  /// Nils out the session identifier and date
  internal static func clearSessionIdentifier() {
    storedSessionIdentifier = nil
    storedSessionIdentifierDate = nil
  }

  /// Persisted session identifier value
  internal static var storedSessionIdentifier = UserDefaults.standard.string(
    forKey: sessionIdentifierKey
  )
  {
    didSet {
      UserDefaults.standard.set(storedSessionIdentifier, forKey: sessionIdentifierKey)
      UserDefaults.standard.synchronize()
    }
  }

  /// Persisted session identifier date value
  internal static var storedSessionIdentifierDate
    = UserDefaults.standard.object(forKey: sessionIdentifierDateKey) as? Date
  {
    didSet {
      UserDefaults.standard.set(storedSessionIdentifierDate, forKey: sessionIdentifierDateKey)
      UserDefaults.standard.synchronize()
    }
  }

  /// Is the session identifier date within the expired time interval
  internal static var isSessionIdentifierValid: Bool {
    guard let date = storedSessionIdentifierDate else { return false }
    return abs(date.timeIntervalSinceNow) < sessionIdentifierExpirationTime
  }
}

// MARK: - User Agent

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension FritzCore {

  /// User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
  /// Example: `iOS Example/1.0 (com.example.Company; build:1; iOS 10.0.0) Fritz/1.0.0`
  internal static let userAgent: String = {
    let sdkVersion: String = {
      guard
        let info = Bundle(for: APIClient.self).infoDictionary,
        let version = info["FritzSDKVersion"]
      else { return "Unknown" }
      return "Fritz/\(version)"
    }()

    guard let info = Bundle.main.infoDictionary else { return "\(sdkVersion)" }

    let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
    let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
    let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
    let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"

    let osNameVersion: String = {
      let version = ProcessInfo.processInfo.operatingSystemVersion
      let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
      let osName: String = {
        #if os(iOS)
          return "iOS"
        #elseif os(watchOS)
          return "watchOS"
        #elseif os(tvOS)
          return "tvOS"
        #elseif os(macOS)
          return "OS X"
        #elseif os(Linux)
          return "Linux"
        #else
          return "Unknown"
        #endif
      }()
      return "\(osName) \(versionString)"
    }()

    let deviceModelName: String = {
      // Taken from: https://stackoverflow.com/a/30075200
      // It seems that older versions of UIDevice would return this through other methods, but
      // This seems to work for now.
      // Note. I have not actually tested this on a real device yet... but a start.
      if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
        return simulatorModelIdentifier
      }
      var sysinfo = utsname()
      _ = uname(&sysinfo)
      return
        String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)?
        .trimmingCharacters(in: .controlCharacters) ?? "Unknown"
    }()

    return
      "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); platform:ios; \(osNameVersion); \(deviceModelName)) \(sdkVersion)"
  }()
}

extension Date {
  public func elapsed() -> Double {
    return Date().timeIntervalSince(self)
  }
}
