//
//  OperationRetrier.swift
//  Fritz
//
//  Created by Andrew Barba on 11/6/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

public enum RetryResult {
  case success
  case error
}

public struct OperationRetryHandler {

  /// Queue to dispatch retry operation on
  public let retryQueue: DispatchQueue

  /// Perform a retry and call completion handler with result of retry
  public let retry: (@escaping (RetryResult) -> Void) -> Void

  /// Retrier received a successful retry, will not retry again
  public let onSuccess: () -> Void

  /// Retrier retried the maximum number of times, will not retry again
  public let onFailure: (UInt) -> Void
}

public final class OperationRetrier {

  /// Delegate to handle retry cases
  public let handler: OperationRetryHandler

  /// Maximum number of times to retry a request
  public let maxRetries: UInt

  /// Millisecond multiplier to adjust exponential curve
  public let exponentialMultiplier: UInt32

  /// Is the retry loop currently paused
  public private(set) var isPaused: Bool = true

  /// Number of attempted retries
  public private(set) var attemptedRetries: UInt = 0

  public init(handler: OperationRetryHandler, maxRetries: UInt, exponentialMultiplier: UInt32) {
    self.handler = handler
    self.maxRetries = maxRetries
    self.exponentialMultiplier = exponentialMultiplier
  }

  /// Start the retry loop
  public func start() {
    guard isPaused else { return }
    isPaused = false
    retryAfterNextDeadline()
  }

  /// Stops the retry loop
  public func stop() {
    isPaused = true
  }

  private func retryAfterNextDeadline() {
    guard !isPaused else { return }
    handler.retryQueue.asyncAfter(deadline: nextRetryDeadline) {
      self.retry()
    }
  }

  private func retry() {
    guard !isPaused else { return }
    attemptedRetries += 1
    handler.retry { self.handleRetryResult($0) }
  }

  private func handleRetryResult(_ result: RetryResult) {
    switch result {
    case .success:
      handler.onSuccess()
    case .error:
      if attemptedRetries < maxRetries {
        retryAfterNextDeadline()
      } else {
        handler.onFailure(attemptedRetries)
      }
    }
  }

  private var nextRetryDeadline: DispatchTime {
    let base = Double(2)
    let exponent = Double(attemptedRetries)
    let milliseconds = pow(base, exponent) * Double(exponentialMultiplier)
    let millisecondJitter = arc4random_uniform(exponentialMultiplier * 10)
    let waitTime = Int(milliseconds) + Int(millisecondJitter)
    return .now() + .milliseconds(waitTime)
  }
}
