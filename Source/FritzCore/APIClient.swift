//
//  APIClient.swift
//  Fritz
//
//  Created by Andrew Barba on 9/18/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

/// Type of content we expect from API
private let httpContentType = "application/json"

/// Represents an HTTP response
public enum Response {
  case success(data: Data)
  case error(error: Error, response: HTTPURLResponse?, data: Data?)
}

/// Represents an internal HTTP client error
public enum RequestError: Error {
  case invalidData
  case invalidResponse
  case invalidURL
  case statusCode
}

internal struct FritzRequestError: Codable {
  /// The error message from the API
  public let message: String

  /// The error category
  public let error: String

  /// if this error should force an app crash.
  public let isFatal: Bool

  /// Mapping from json
  private enum CodingKeys: String, CodingKey {
    case isFatal = "is_fatal"
    case message
    case error
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.message = try values.decodeIfPresent(String.self, forKey: .message) ?? ""
    self.error = try values.decodeIfPresent(String.self, forKey: .error) ?? ""
    self.isFatal = try values.decodeIfPresent(Bool.self, forKey: .isFatal) ?? false
  }
}

/// Type to handle network request completion
public typealias RequestCompletionHandler = (Response) -> Void

/// Type to represent request body/url options
public typealias RequestOptions = [String: Any]

/// Type to represent request headers
public typealias RequestHeaders = [HTTPHeader: String]

/// HTTP methods we use
public enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}

/// HTTP headers we use
public enum HTTPHeader: String {
  case appToken = "x-fritz-token"
  case contentType = "content-type"
  case instanceIdentifier = "x-fritz-instance-id"
  case sessionIdentifier = "x-fritz-session-id"
  case userAgent = "user-agent"
  case contentEncoding = "content-encoding"
  case contentLength = "content-length"
}

/// Class for communicating with the Fritz API
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public final class APIClient {

  /// Private logger instance
  private let logger = Logger(name: "APIClient")

  /// Session to make requests in
  public let session: Session

  /// URL session for sending short lived requests in the foreground
  private let ephemeralURLSession = URLSession(configuration: .ephemeral)

  /// Required initializer
  public required init(session: Session) {
    self.session = session
  }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension APIClient {

  /// Create a json data task
  @discardableResult
  public func dataTask(_ request: URLRequest, completionHandler: RequestCompletionHandler? = nil)
    -> URLSessionDataTask
  {
    let task = ephemeralURLSession.dataTask(with: request) { data, response, error in
      guard let completionHandler = completionHandler else { return }
      let response = self.processRequestCompletion(data, response: response, error: error)
      completionHandler(response)
    }
    task.resume()
    return task
  }

  /// Perform GET request to Fritz API
  @discardableResult
  public func get(
    path: String,
    options: RequestOptions? = nil,
    headers: RequestHeaders? = nil,
    completionHandler: RequestCompletionHandler? = nil
  ) -> URLRequest {
    let request = urlRequest(.get, path: path, options: options, headers: headers)
    dataTask(request, completionHandler: completionHandler)
    return request
  }

  /// Perform POST request to Fritz API
  @discardableResult
  public func post(
    path: String,
    options: RequestOptions? = nil,
    headers: RequestHeaders? = nil,
    completionHandler: RequestCompletionHandler? = nil
  ) -> URLRequest {
    let request = urlRequest(.post, path: path, options: options, headers: headers)
    dataTask(request, completionHandler: completionHandler)
    return request
  }

  /// Perform PUT request to Fritz API
  @discardableResult
  public func put(
    path: String,
    options: RequestOptions? = nil,
    headers: RequestHeaders? = nil,
    completionHandler: RequestCompletionHandler? = nil
  ) -> URLRequest {
    let request = urlRequest(.put, path: path, options: options, headers: headers)
    dataTask(request, completionHandler: completionHandler)
    return request
  }

  /// Perform DELETE request to Fritz API
  @discardableResult
  public func delete(
    path: String,
    options: RequestOptions? = nil,
    headers: RequestHeaders? = nil,
    completionHandler: RequestCompletionHandler? = nil
  ) -> URLRequest {
    let request = urlRequest(.delete, path: path, options: options, headers: headers)
    dataTask(request, completionHandler: completionHandler)
    return request
  }

  /// Builds a URL request based on a given HTTP method and options
  private func urlRequest(
    _ httpMethod: HTTPMethod,
    path: String,
    options: RequestOptions? = nil,
    headers: RequestHeaders? = nil
  ) -> URLRequest {
    logger.debug(httpMethod.rawValue, path, options ?? [:])

    // Build fritz api url
    // swiftlint:disable:next force_unwrapping
    let url = path.contains("://") ? URL(string: path)! : URL(string: session.apiUrl + path)!

    // Build request object
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)

    // Merge additional headers, overriding default
    let headers = defaultRequestHeaders.merging(headers ?? [:]) { $1 }

    // Apply request headers
    for (header, value) in headers {
      request.addValue(value, forHTTPHeaderField: header.rawValue)
    }

    // Method
    request.httpMethod = httpMethod.rawValue

    // Parse options, apply to body or url based on method
    if let options = options {
      switch httpMethod {
      case .get, .delete:
        request.url = URL(string: url.absoluteString + "?" + urlEncodedQueryString(options))
      case .post, .put:
        guard let data = try? JSONSerialization.data(withJSONObject: options, options: []) else {
          break
        }

        if SessionSettings.settings(for: session).gzipTrackEvents, let data = try? data.gzipped(),
          data.count > 0
        {
          request.setValue("gzip", forHTTPHeaderField: HTTPHeader.contentEncoding.rawValue)
          request.httpBody = data
        } else {
          request.httpBody = data
        }
      }
    }

    return request
  }

  /// Default request headers sent on all requests
  private var defaultRequestHeaders: RequestHeaders {
    return [
      .contentType: httpContentType,
      .appToken: session.apiKey,
      .sessionIdentifier: FritzCore.sessionIdentifier,
      .instanceIdentifier: FritzCore.instanceIdentifier,
      .userAgent: FritzCore.userAgent,
    ]
  }

  /// Converts a dict to url encoded query string
  private func urlEncodedQueryString(_ options: RequestOptions) -> String {
    let queryParts: [String] = options.compactMap { option in
      guard
        let safeKey = option.key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
        let safeValue = "\(option.value)".addingPercentEncoding(
          withAllowedCharacters: .urlHostAllowed
        )
      else { return nil }
      return "\(safeKey)=\(safeValue)"
    }
    return queryParts.joined(separator: "&")
  }

  /// Process a response
  private func processRequestCompletion(_ data: Data?, response: URLResponse?, error: Swift.Error?)
    -> Response
  {
    if let error = error {
      logger.warn("Request Error:", error)
      return .error(error: error, response: response as? HTTPURLResponse, data: nil)
    }

    guard let data = data else {
      logger.warn("Request Data Error:", "data is nil")
      return .error(
        error: RequestError.invalidData,
        response: response as? HTTPURLResponse,
        data: nil
      )
    }

    guard let httpResponse = response as? HTTPURLResponse else {
      logger.warn("Request Response Error:", "response is not an http response")
      return .error(
        error: RequestError.invalidResponse,
        response: response as? HTTPURLResponse,
        data: data
      )
    }

    guard let url = httpResponse.url else {
      logger.warn("Request URL Error:", "url is nil")
      return .error(error: RequestError.invalidURL, response: httpResponse, data: data)
    }

    switch httpResponse.statusCode {
    case 200..<400:
      return .success(data: data)
    default:
      logger.error("Request Failed:", httpResponse.statusCode, url)
      return .error(error: RequestError.statusCode, response: httpResponse, data: data)
    }
  }
}
