//
//  BatchedRequestQueue.swift
//  Fritz
//
//  Created by Christopher Kelly on 11/3/17.
//  Updated by Andrew Barba on 11/4/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//


/// Default to 10 retries, last retry is ~1 hour
public let defaultMaxRetries: UInt = 12

/// Status codes to retry if received
public let defaultRetryStatusCodes: Set<Int> = [502, 503]

/// Error codes to retry
public let defaultRetryErrorCodes: Set<Int> = [
  NSURLErrorNotConnectedToInternet,
  NSURLErrorTimedOut,
  NSURLErrorUnknown,
]

/// 1 second multiplier for exponential backoff
public let defaultExponentialMultiplier: UInt32 = 1000


/// This class attemmpts to strategically batch send requests and batch retry requests on failures.
/// The main flow of this class looks like:
/// 
/// SUCCESS:
/// 1. Add event to queue
/// 2. If threshold met, flush the queue
/// 3. Flush was successful
/// 
/// FAILURE
/// 1. Add event to queue
/// 2. If threshold met, flush the queue
/// 3. Flush failed
/// 4. Add items back into items array
/// 5. Stop processing queue (maintenance mode)
/// 5. If a healthcheck retrier is not currently waiting, create one and start waiting for a successful healthcheck
/// 
/// HEALTHCHECK SUCCESS
/// 1. We received a successful healthcheck
/// 2. Start processing items again (disable maintenance mode)
/// 
/// HEALTHCHECK FAILURE
/// 1. We received a failed healthcheck, exponential backoff and retry health check
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public final class BatchedRequestQueue<Element> {

  public typealias FlushHandler = ([Element], @escaping RequestCompletionHandler) -> Void

  public typealias HealthcheckHandler = (@escaping (Bool) -> Void) -> Void

  private let session: Session

  /// Number of events to store before flushing queue
  public var batchThreshold: () -> UInt

  /// Number of seconds before flushing queue
  public var flushInterval: TimeInterval {
    return SessionSettings.settings(for: session).batchFlushInterval
  }

  /// Queue to call delegate methods on
  public let flushQueue: DispatchQueue

  /// Maximum number of times to retry a request
  public let maxRetries: UInt

  /// Status codes to retry a request
  public let retryStatusCodes: Set<Int>

  /// Error codes to retry a request
  public let retryErrorCodes: Set<Int>

  /// Pass through to OperationRetrier
  public let exponentialMultiplier: UInt32

  /// Block to be called on flush
  public var onFlush: FlushHandler?

  /// Block to be called when asking for a healthcheck
  public var apiHealthcheck: HealthcheckHandler?

  /// Current items in queue
  public private(set) var items: [Element] = []

  /// If true, we are processing available items, if false we are waiting for API to recover
  public private(set) var isApiHealthy = true

  /// A retrier that requests a healhtcheck from our api before retrying batches
  private var healthcheckRetrier: OperationRetrier?

  /// Flush items on each timer fire
  private var flushTimer: Timer?

  /// Private queue to guard items array
  private let itemsQueue = DispatchQueue(label: "com.fritz.sdk.batch-request-queue.items")

  public init(
    session: Session,
    flushQueue: DispatchQueue,
    getBatchThreshold: @escaping (Session) -> UInt = { (session: Session) in
        return UInt(SessionSettings.settings(for: session).trackRequestBatchSize)
    },
    maxRetries: UInt = defaultMaxRetries,
    retryStatusCodes: Set<Int> = defaultRetryStatusCodes,
    retryErrorCodes: Set<Int> = defaultRetryErrorCodes,
    exponentialMultiplier: UInt32 = defaultExponentialMultiplier
  ) {
    self.session = session
    self.flushQueue = flushQueue
    self.maxRetries = maxRetries
    self.batchThreshold = { getBatchThreshold(session) }
    self.retryStatusCodes = retryStatusCodes
    self.retryErrorCodes = retryErrorCodes
    self.exponentialMultiplier = exponentialMultiplier
    self.flushTimer
      = Timer.scheduledTimer(withTimeInterval: flushInterval, repeats: true) { [weak self] _ in
        self?.handleFlushTimerFired()
      }
  }

  deinit {
    healthcheckRetrier?.stop()
    healthcheckRetrier = nil
    flushTimer?.invalidate()
    flushTimer = nil
  }

  /// Add an item to the queue
  public func add(_ item: Element) {
    itemsQueue.sync {
      // Add items to queue
      items.append(item)

      // If api is healthy, and we hit a threshold, flush and clear items
      if isApiHealthy, items.count >= batchThreshold() {
        flush(items: items)
        items = []
      }
    }
  }

  /// Flush all items, if force is true then will flush regardless of healthy api
  public func flush(force: Bool = false) {
    itemsQueue.sync {
      // If api is healthy or force
      if force || isApiHealthy {
        flush(items: items)
        items = []
      }
    }
  }

  /// Clears all items in the queue WITHOUT flushing
  public func clear() {
    itemsQueue.sync {
      items = []
    }
  }

  private func flush(items: [Element]) {
    guard let handler = onFlush, !items.isEmpty else { return }
    flushQueue.async {
      handler(items) { [weak self] in self?.handleFlushResponse($0, items: items) }
    }
  }

  private func handleFlushResponse(_ response: Response, items: [Element]) {
    if didApiFail(with: response) {
      handleApiFailure(for: items)
    }
  }

  private func handleApiFailure(for items: [Element]) {
    itemsQueue.sync {
      // Stop processing until healthcheck passes
      isApiHealthy = false

      // Add items back to queue
      self.items += items

      // Create a healthcheck if we dont have one already
      guard healthcheckRetrier == nil else { return }
      let retrier = createHealthcheckRetrier()
      retrier.start()
      healthcheckRetrier = retrier
    }
  }

  private func createHealthcheckRetrier() -> OperationRetrier {
    let handler = OperationRetryHandler(
      retryQueue: flushQueue,
      retry: { [weak self] in self?.retryHealthcheck(completionHandler: $0) },
      onSuccess: { [weak self] in self?.handleHealthcheckSucceeded() },
      onFailure: { [weak self] _ in self?.handleHealthcheckFailed() }
    )
    return OperationRetrier(
      handler: handler,
      maxRetries: maxRetries,
      exponentialMultiplier: exponentialMultiplier
    )
  }

  private func handleHealthcheckSucceeded() {
    itemsQueue.sync {
      // Start processing again
      isApiHealthy = true

      // Retry items
      flush(items: items)

      // Clear items
      items = []

      // Remove healthcheck
      healthcheckRetrier = nil
    }
  }

  private func handleHealthcheckFailed() {
    itemsQueue.sync {
      // Re-start healthcheck loop
      let retrier = createHealthcheckRetrier()
      retrier.start()
      healthcheckRetrier = retrier
    }
  }

  private func handleFlushTimerFired() {
    itemsQueue.sync {
      // Ensure api is healthy
      guard isApiHealthy else { return }

      // Flush items
      flush(items: items)

      // Clear items
      items = []
    }
  }

  private func retryHealthcheck(completionHandler: @escaping (RetryResult) -> Void) {
    guard let handler = apiHealthcheck else { return completionHandler(.success) }
    handler { isHealthy in
      isHealthy ? completionHandler(.success) : completionHandler(.error)
    }
  }

  private func didApiFail(with response: Response) -> Bool {
    switch response {
    case .error(let error, let httpResponse, _):
      return didApiFail(with: error) || didApiFail(with: httpResponse)
    default:
      return false
    }
  }

  private func didApiFail(with httpResponse: HTTPURLResponse?) -> Bool {
    guard let statusCode = httpResponse?.statusCode else { return false }
    return retryStatusCodes.contains(statusCode)
  }

  private func didApiFail(with error: Error) -> Bool {
    switch error {
    case let error as NSError where error.domain == NSURLErrorDomain:
      return retryErrorCodes.contains(error.code)
    default:
      return false
    }
  }
}
