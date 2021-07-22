//
//  MLFeatureProvider+JSON.swift
//  Fritz
//
//  Created by Andrew Barba on 2/6/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import CoreML
import FritzCore

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension MLFeatureProvider {

  /// Converts every feature in the provider to JSON to send to the server
  internal func toJSON() -> RequestOptions {
    var json: RequestOptions = [
      "features": Array(featureNames),
    ]

    let featureData: RequestOptions = featureNames.reduce([:]) {
      (result, featureName) -> RequestOptions in
      guard let feature = self.featureValue(for: featureName) else { return result }
      let json: RequestOptions = [featureName: feature.toJSON()]
      return result.merging(json, uniquingKeysWith: { key, _ in key })
    }

    json["data"] = featureData

    return json
  }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension MLFeatureValue {

  /// Converts a feature to JSON to send to the server
  internal func toJSON() -> RequestOptions {
    let type: String
    let value: Any

    switch self.type {
    case .string:
      type = "string"
      value = stringValue
    case .int64:
      type = "int"
      value = int64Value
    case .double:
      type = "double"
      value = doubleValue
    case .image:
      type = "image"
      value = NSNull()
    case .dictionary:
      type = "dictionary"
      value = NSNull()
    case .multiArray:
      type = "array"
      value = NSNull()
    case .invalid:
      type = "invalid"
      value = NSNull()
    case .sequence:
      type = "sequence"
      value = NSNull()
    @unknown default:
      type = "unknown"
      value = NSNull()
    }

    return ["type": type, "value": value]
  }
}
