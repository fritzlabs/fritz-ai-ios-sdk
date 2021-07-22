//
//  Logger.swift
//  Fritz
//
//  Created by Andrew Barba on 12/28/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

/// Logging level for the SDK
///
/// - debug: log all logs
/// - info: log info logs or higher
/// - warn: log warning logs or higher
/// - error: log error logs only
/// - none: disable logging
@objc
public enum LogLevel: Int {
  case debug = 0
  case info
  case warn
  case error
  case none

  public static var shared: LogLevel = .error
}

public struct Logger {

  public let level: LogLevel

  public let name: String

  public init(name: String, level: LogLevel = .shared) {
    self.name = name
    self.level = level
  }

  /// Prints to stdout when level is `debug`
  public func debug(_ items: Any...) {
    guard isEnabled(for: .debug) else { return }
    let line = items.map { String(describing: $0) }.joined(separator: " ")
    print("[Fritz] debug: \(name) \(line)")
  }

  /// Prints to stdout when level is `info` or lower
  public func info(_ items: Any...) {
    guard isEnabled(for: .info) else { return }
    let line = items.map { String(describing: $0) }.joined(separator: " ")
    print("[Fritz] info: \(name) \(line)")
  }

  /// Prints to stdout when level is `warn` or lower
  public func warn(_ items: Any...) {
    guard isEnabled(for: .warn) else { return }
    let line = items.map { String(describing: $0) }.joined(separator: " ")
    print("[Fritz] warn: \(name) \(line)")
  }

  /// Prints to stdout when level is `error` or lower
  public func error(_ items: Any...) {
    guard isEnabled(for: .error) else { return }
    let line = items.map { String(describing: $0) }.joined(separator: " ")
    print("[Fritz] error: \(name) \(line)")
  }

  /// Prints to stdout
  /// - Note: Should use one of the functions above that are controlled by log level
  public func log(_ items: Any...) {
    let line = items.map { String(describing: $0) }.joined(separator: " ")
    print("[Fritz] \(name) \(line)")
  }

  private func isEnabled(for level: LogLevel) -> Bool {
    return self.level.rawValue <= level.rawValue
  }
}
