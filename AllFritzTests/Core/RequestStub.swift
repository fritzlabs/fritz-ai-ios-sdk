//
//  RequestStub.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 11/14/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import Hippolyte
@testable import FritzManagedModel


extension String {

  func format(_ arguments: [CVarArg]) -> String {
    let args = arguments.map {
      if let arg = $0 as? Int { return String(arg) }
      if let arg = $0 as? Float { return String(arg) }
      if let arg = $0 as? Double { return String(arg) }
      if let arg = $0 as? Int64 { return String(arg) }
      if let arg = $0 as? String { return String(arg) }

      return "(null)"
    } as [CVarArg]

    return String.init(format: self, arguments: args)
  }
}


class RequestStub {

  enum FritzTestUrl: String {

    case settings = "/session/settings"
    case activeModel = "/model/%@/active"
    case annotationRecordings = "/model/annotation"

    var fullURL: URL {
      return URL(string: fullPath)!
    }
    var fullPath: String {
      return FritzTestCase.testSession.apiUrl + self.rawValue
    }
    func fullPath(_ parameters: String...) -> String {
      return fullPath(parameters)
    }
    func fullPath(_ parameters: [String]) -> String {
      return self.rawValue.format(parameters)
    }

    var exactMatch: RegexMatcher {
      let regex = try! NSRegularExpression(pattern: fullPath, options: [])
      return RegexMatcher(regex: regex)
    }
    func exactMatch(_ parameters: String...) -> RegexMatcher {
      let regex = try! NSRegularExpression(pattern: fullPath(parameters), options: [])
      return RegexMatcher(regex: regex)
    }

    var matchPrefix: RegexMatcher {
      let regex = try! NSRegularExpression(pattern: fullPath + "+", options: [])
      return RegexMatcher(regex: regex)
    }
    func matchPrefix(_ parameters: String...) -> RegexMatcher {
      let regex = try! NSRegularExpression(pattern: fullPath(parameters) + "+", options: [])
      return RegexMatcher(regex: regex)
    }
  }


  func activeModel(_ modelType: SwiftIdentifiedModel.Type) -> StubRequest {
    let activeModel = ActiveServerModel(
      id: modelType.modelIdentifier,
      version: modelType.packagedModelVersion,
      src: nil,
      tags: nil,
      metadata: nil
    )

    let data = try! JSONEncoder().encode(activeModel)

    let response = StubResponse.Builder()
      .stubResponse(withStatusCode: 200)
      .addBody(data)
      .build()

    let matcher = FritzTestUrl.activeModel.matchPrefix(modelType.modelIdentifier)
    let request = StubRequest.Builder()
      .stubRequest(withMethod: .GET, urlMatcher: matcher)
      .addResponse(response)
      .build()

    return request


  }
  func sessionSettings(_ settings: SessionSettings = .init()) -> StubRequest {
    let data = try! JSONEncoder().encode(settings)

    let response = StubResponse.Builder()
      .stubResponse(withStatusCode: 200)
      .addBody(data)
      .build()

    let matcher = FritzTestUrl.settings.matchPrefix
    let request = StubRequest.Builder()
      .stubRequest(withMethod: .GET, urlMatcher: matcher)
      .addResponse(response)
      .build()

    return request
  }

  func annotationRecordings() -> StubRequest {
    let matcher = FritzTestUrl.annotationRecordings.matchPrefix
    let request = StubRequest.Builder()
      .stubRequest(withMethod: .POST, urlMatcher: matcher)
      .build()

    return request

  }
}
