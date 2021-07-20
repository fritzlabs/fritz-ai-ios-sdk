//
//  ModelDebugOutput.swift
//  FritzManagedModel
//
//  Created by Christopher Kelly on 4/17/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

let imageKey = "image"

@available(iOS 11.0, *)
public struct ModelDebugOutput<T: RawRepresentable> where T.RawValue == String {
  var data: [String: Any] = [:]
  public let prefix: String

  public init(prefix: String) {
    self.prefix = prefix
  }

  public subscript(key: T) -> Any? {
    get { return data[key.rawValue] }
    set { data[key.rawValue] = newValue }
  }

  public var image: UIImage? {
    get {
      return data[imageKey] as? UIImage
    }
    set {
      data[imageKey] = newValue
    }
  }

  var encodedImage: String? {
    if let value = self.data[imageKey],
      let uiImage = value as? UIImage,
      let encoded = uiImage.jpegData(compressionQuality: 0.5)
    {
      return encoded.base64EncodedString()
    } else {
      return nil
    }
  }

  public func write() {
    if let data = toData() {
      try! SessionManager.localModelManager.writeModelOutput(
        name: "poselifting_\(prefix)",
        data: data
      )
    }
  }

  public func toData() -> Data? {
    var encodedData = self.data

    if let encodedImage = encodedImage {
      encodedData[imageKey] = encodedImage
    }

    guard let data = try? JSONSerialization.data(withJSONObject: encodedData, options: []) else {
      return nil
    }
    return data
  }
}
