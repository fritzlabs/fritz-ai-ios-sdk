//
//  SessionSettings.swift
//  Fritz
//
//  Created by Andrew Barba on 11/28/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public struct SessionSettings: Codable {

  /// If false, no calls will be made to the API
  public let apiRequestsEnabled: Bool

  /// Settings refresh interval
  public let settingsRefreshInterval: TimeInterval

  /// Control model I/O sampling based on ratio, 0-1
  public let modelInputOutputSamplingRatio: Float

  /// Control batch size of track requests
  public let trackRequestBatchSize: Int

  /// Control if events are gzipped in track response
  public let gzipTrackEvents: Bool

  /// Batch request flush interval in seconds
  public let batchFlushInterval: Double

  /// List of events we should not track
  public let eventBlacklist: Set<String>

  /// TimeInterval to refresh active model settings from the server.
  public let activeModelRefreshInterval: TimeInterval

  /// If true, annotations can be sent to the API.
  public let recordAnnotationsEnabled: Bool

  /// Control batch size of track requests
  public let annotationRequestBatchSize: Int

  /// Mapping from json
  private enum CodingKeys: String, CodingKey {
    case apiRequestsEnabled = "api_requests_enabled"
    case settingsRefreshInterval = "settings_refresh_interval"
    case modelInputOutputSamplingRatio = "model_input_output_sampling_ratio"
    case trackRequestBatchSize = "track_request_batch_size"
    case gzipTrackEvents = "gzip_track_events"
    case batchFlushInterval = "batch_flush_interval"
    case eventBlacklist = "event_blacklist"
    case activeModelRefreshInterval = "active_model_refresh_interval_sec"
    case recordAnnotationsEnabled = "record_annotations_enabled"
    case annotationRequestBatchSize = "annotation_request_batch_size"
  }

  public init(
    apiRequestsEnabled: Bool = false,
    settingsRefreshInterval: TimeInterval = 30 * 60,
    modelInputOutputSamplingRatio: Float = 0,
    gzipTrackEvents: Bool = false,
    trackRequestBatchSize: Int = 100,
    batchFlushInterval: Double = 60.0,
    eventBlacklist: Set<String> = [],
    activeModelRefreshInterval: TimeInterval = 15 * 60,
    recordAnnotationsEnabled: Bool = false,
    annotationRequestBatchSize: Int = 10
  ) {
    self.apiRequestsEnabled = apiRequestsEnabled
    self.settingsRefreshInterval = settingsRefreshInterval
    self.modelInputOutputSamplingRatio = modelInputOutputSamplingRatio
    self.trackRequestBatchSize = trackRequestBatchSize
    self.gzipTrackEvents = gzipTrackEvents
    self.batchFlushInterval = batchFlushInterval
    self.eventBlacklist = eventBlacklist
    self.activeModelRefreshInterval = activeModelRefreshInterval
    self.recordAnnotationsEnabled = recordAnnotationsEnabled
    self.annotationRequestBatchSize = annotationRequestBatchSize
  }
}

// MARK: - Static

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SessionSettings {

  /// Private cache to read settings from
  private static var cache: [String: SessionSettings] = [:]

  /// Returns cached settings for a session, or default settings if not cached
  public static func settings(for session: Session) -> SessionSettings {
    return cache[session.apiKey, default: SessionSettings()]
  }

  /// Updates the cached settings for a session
  public static func setSettings(_ settings: SessionSettings, for session: Session) {
    cache[session.apiKey] = settings
  }

  /// Resets session settings, clearing cache.
  internal static func clearCache() {
    cache = [:]
  }
}

// MARK: - Sampling

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension SessionSettings {

  private static let samplePrecision: UInt32 = 1000

  /// Randomly decides whether we should sample based on the I/O percentage
  public func shouldSampleInputOutput() -> Bool {
    let randomInt = arc4random_uniform(SessionSettings.samplePrecision)
    let randomFloat = Float(randomInt) / Float(SessionSettings.samplePrecision)
    return modelInputOutputSamplingRatio > randomFloat
  }
}
