//
//  ModelDownloader.swift
//  Fritz
//
//  Created by Andrew Barba on 12/2/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import FritzCore

/// Represents an HTTP download response
internal enum DownloadResponse {
  case success(url: URL)
  case error(error: Error, response: HTTPURLResponse?)
}

internal enum DownloadErrors: Error {
  case downloadFailed
}

/// Type to handle download request completion
internal typealias DownloadRequestCompletionHandler = (DownloadResponse) -> Void

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
internal class ModelDownloader {

  /// Shared downloader
  static let shared = ModelDownloader()

  /// URL session for sending long running background requests, like downloading a model
  private let urlSession: URLSession

  /// Private serial queue for model downloads
  private let downloadQueue = DispatchQueue(label: "com.fritz.sdk.ModelDownloader")

  /// Force shared downloader
  private init() {
    let configuration = URLSessionConfiguration.default
    configuration.allowsCellularAccess = true

    // Indicates whether the session should wait for connectivity to become available, or fail immediately
    configuration.waitsForConnectivity = true

    let delegate = BackgroundSessionDelegate.shared

    let delegateQueue = OperationQueue()
    delegateQueue.maxConcurrentOperationCount = 1
    delegateQueue.underlyingQueue = downloadQueue

    self.urlSession
      = URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)
  }

  /// Perform GET request to download large files using the background session
  @discardableResult
  func download(
    for modelConfig: FritzModelConfiguration,
    modelAtURL url: URL,
    completionHandler: DownloadRequestCompletionHandler? = nil
  ) -> URLRequest {
    let allowsCellularAccess = !modelConfig.wifiRequiredForModelDownload
    var request = URLRequest(url: url)
    request.allowsCellularAccess = allowsCellularAccess
    var task: URLSessionDownloadTask

    // Resume download if it was previously interrupted
    // Delete the resume data cache if found
    if let resumeCache = UserDefaults.standard.object(forKey: url.absoluteString) as? Data {
      task = urlSession.downloadTask(withResumeData: resumeCache)
      UserDefaults.standard.removeObject(forKey: url.absoluteString)
    } else {
      task = urlSession.downloadTask(with: request)
    }

    BackgroundSessionDelegate.shared.completionHandlers[task] = completionHandler
    task.resume()
    return request
  }
}

private class BackgroundSessionDelegate: NSObject, URLSessionDownloadDelegate {

  static let shared = BackgroundSessionDelegate()

  var completionHandlers: [URLSessionTask: DownloadRequestCompletionHandler] = [:]

  func urlSession(
    _ session: URLSession,
    downloadTask: URLSessionDownloadTask,
    didFinishDownloadingTo location: URL
  ) {
    if let httpResponse = downloadTask.response as? HTTPURLResponse,
      (200...299).contains(httpResponse.statusCode)
    {
      let completionHandler = completionHandlers[downloadTask]
      completionHandler?(.success(url: location))
    } else {
      let completionHandler = completionHandlers[downloadTask]
      completionHandler?(
        .error(
          error: DownloadErrors.downloadFailed,
          response: downloadTask.response as? HTTPURLResponse
        )
      )
    }
  }

  func urlSession(
    _ session: URLSession,
    task: URLSessionTask,
    didCompleteWithError error: Error?
  ) {
    guard let error = error else { return }

    // Attempt to cache data to resume the download later
    let userInfo = (error as NSError).userInfo
    if let request = task.originalRequest, let url = request.url,
      let resumeData = userInfo[NSURLSessionDownloadTaskResumeData] as? Data
    {
      UserDefaults.standard.set(resumeData, forKey: url.absoluteString)
    }

    let completionHandler = completionHandlers[task]
    completionHandler?(.error(error: error, response: task.response as? HTTPURLResponse))
  }
}
