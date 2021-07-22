//
//  SessionManager.swift
//  Fritz
//
//  Created by Andrew Barba on 10/31/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public enum SessionManagerError: Error {
  case disabled
}

/// Manages session data.
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public final class SessionManager: NSObject {

  /// Session to make requests in
  public let session: Session

  /// API client to make requests with
  public let apiClient: APIClient

  /// Queue to batch and retry requests
  public let trackRequestQueue: BatchedRequestQueue<SessionEvent>

  public let annotationsRequestQueue: BatchedRequestQueue<SessionEvent>

  /// Default file manager
  public let fileManager: FileManager = .default

  /// Private logger instance
  public let logger = Logger(name: "SessionManager")

  /// Timer to refresh session settings
  private var settingsTimer: Timer?

  /// Internal testing queue for objective c to peek into the items queue.
  @objc internal var trackRequestQueueItemTypes: [String] {
    return trackRequestQueue.items.map { $0.type.rawValue }
  }

  /// Required initializer
  /// - Parameters:
  ///   - session: session
  public init(session: Session) {
    self.session = session
    self.apiClient = APIClient(session: session)
    self.trackRequestQueue = BatchedRequestQueue(
      session: session,
      flushQueue: .main
    )
    self.annotationsRequestQueue = BatchedRequestQueue(
      session: session,
      flushQueue: .main,
      getBatchThreshold: { session in
        return UInt(SessionSettings.settings(for: session).annotationRequestBatchSize)
      }
    )
    super.init()

    self.trackRequestQueue.onFlush = { [weak self] events, completionHandler in
      self?.trackRequestQueue(flushed: events, completionHandler: completionHandler)
    }
    self.trackRequestQueue.apiHealthcheck = { [weak self] completionHandler in
      self?.requestHealthcheck(completionHandler)
    }
    self.annotationsRequestQueue.onFlush = { [weak self] events, completionHandler in
      self?.trackAnnotationsQueue(flushed: events, completionHandler: completionHandler)
    }
    self.annotationsRequestQueue.apiHealthcheck = { [weak self] completionHandler in
      self?.requestHealthcheck(completionHandler)
    }
    self.registerForApplicationLifecycleEvents()
    self.loadSessionSettings()
  }

  /// Track an event, taking into account blacklisted events
  public func trackEvent(_ event: SessionEvent) {
    guard !session.settings.eventBlacklist.contains(event.type.rawValue) else { return }
    trackRequestQueue.add(event)
  }

  /// Track a prediction annotation.
  public func trackAnnotation(_ event: SessionEvent) {
    guard event.type == .predictionAnnotation, session.settings.recordAnnotationsEnabled else { return }
    annotationsRequestQueue.add(event)
  }

  deinit {
    settingsTimer?.invalidate()
    settingsTimer = nil
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK: - Initialize

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SessionManager {

  private func getSessionSettingsFailedMessage() -> String {
    return """
      Invalid Fritz API Key. Check the following:
      - You've included the Fritz-Info.plist file from the webapp.\n" +
      - Your bundle id matches the registered app's bundle id that you set up in Fritz
      For more details, please visit: https://docs.fritz.ai/get-started.html
      """
  }

  /// Loads session settings from API.
  ///
  ///
  /// - Parameter completionHandler: Completion handler to call after request success.
  public func loadSessionSettings(completionHandler: RequestCompletionHandler? = nil) {
    // All sessions get default settings with the API disabled.
    // This effectively disables all model tracking events.
    // OTA downloads and data collection are disabled elsewhere.
    SessionSettings.setSettings(SessionSettings(), for: self.session)
  }

  /// Sets a timer to refresh settings
  private func startSessionSettingsRefreshTimer(interval: TimeInterval) {
    guard settingsTimer == nil else { return }

    settingsTimer
      = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
        self?.logger.debug("Fetching Session Settings...")
        self?.loadSessionSettings()
      }
  }
}

// MARK: - Healthcheck
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SessionManager {

  /// Performs a healthcheck to our backend, returns true in completion handler if healthy
  /// Note: This method does does nothing as there is no longer a backend.
  func requestHealthcheck(_ completionHandler: @escaping (Bool) -> Void) {
    guard session.settings.apiRequestsEnabled else {
      logger.debug("Api Requests Disabled - Skipping Health Check")
      return completionHandler(true)
    }
  }
}

// MARK: - Analytics
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SessionManager {

  /// Posts a tracking event about a model
  /// Note: This method does does nothing as there is no longer a backend.
  internal func trackRequestQueue(
    flushed events: [SessionEvent],
    completionHandler: @escaping RequestCompletionHandler
  ) {
    guard session.settings.apiRequestsEnabled else {
      logger.debug("Api Requests Disabled - Skipping Track Event")
      return completionHandler(
        .error(error: SessionManagerError.disabled, response: nil, data: nil)
      )
    }
  }

  /// Posts a tracking event about a model
  /// Note: This method does does nothing as there is no longer a backend.
  internal func trackAnnotationsQueue(
    flushed events: [SessionEvent],
    completionHandler: @escaping RequestCompletionHandler
  ) {

    guard session.settings.apiRequestsEnabled, session.settings.recordAnnotationsEnabled else {
      logger.debug("Tracking annotations disabled.")
      return completionHandler(
        .error(error: SessionManagerError.disabled, response: nil, data: nil)
      )
    }
  }

  private func registerForApplicationLifecycleEvents() {
    let ncd = NotificationCenter.default
    #if os(iOS) || os(watchOS) || os(tvOS)
      ncd.addObserver(
        self,
        selector: #selector(applicationDidEnterBackground),
        name: UIApplication.didEnterBackgroundNotification,
        object: nil
      )
      ncd.addObserver(
        self,
        selector: #selector(applicationWillEnterForeground),
        name: UIApplication.willEnterForegroundNotification,
        object: nil
      )
      ncd.addObserver(
        self,
        selector: #selector(applicationDidBecomeActive),
        name: UIApplication.didBecomeActiveNotification,
        object: nil
      )
      ncd.addObserver(
        self,
        selector: #selector(applicationWillResignActive),
        name: UIApplication.willResignActiveNotification,
        object: nil
      )
    #elseif os(macOS)
      ncd.addObserver(
        self,
        selector: #selector(applicationWillResignActive),
        name: .NSApplicationWillResignActiveNotification,
        object: nil
      )
      ncd.addObserver(
        self,
        selector: #selector(applicationDidBecomeActive),
        name: .NSApplicationDidBecomeActiveNotification,
        object: nil
      )
    #endif
  }

  @objc
  private func applicationDidEnterBackground(_: Any) {
    FritzCore.extendSessionIdentifier()
    trackEvent(.init(type: .applicationDidEnterBackground, data: [:]))
    trackRequestQueue.flush()
    annotationsRequestQueue.flush()
  }

  @objc
  private func applicationWillEnterForeground(_: Any) {
    FritzCore.resetSessionIdentifierIfNeeded()
    trackEvent(.init(type: .applicationWillEnterForeground, data: [:]))
  }

  @objc
  private func applicationDidBecomeActive(_: Any) {
    FritzCore.resetSessionIdentifierIfNeeded()
    trackEvent(.init(type: .applicationDidBecomeActive, data: [:]))
  }

  @objc
  private func applicationWillResignActive(_: Any) {
    FritzCore.extendSessionIdentifier()
    trackEvent(.init(type: .applicationWillResignActive, data: [:]))
  }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SessionEvent {

  internal func toRequestOptions() -> RequestOptions {
    return [
      "type": type.rawValue,
      "timestamp": timestamp,
      "session_id": sessionIdentifier,
      "data": data,
    ]
  }
}
