//
//  FritzPredictorProtocol+Download.swift
//  Fritz
//
//  Created by Christopher Kelly on 3/27/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
public protocol DownloadableModel: FritzMLModelInitializable {

  static var modelConfig: FritzModelConfiguration { get }

  static var managedModel: FritzManagedModel { get }

  static var wifiRequiredForModelDownload: Bool { get set }

  static func fetchModel(completionHandler: @escaping (Self?, Error?) -> Void)
}

@available(iOS 11.0, *)
extension DownloadableModel {

  // Internal function used that is called by code that needs to be exposed to Obj-C.
  public static var _wifiRequiredForModelDownload: Bool {
    get {
      return modelConfig.wifiRequiredForModelDownload
    }
    set {
      modelConfig.wifiRequiredForModelDownload = newValue
    }
  }

  public static func _fetchModel(completionHandler: @escaping (Self?, Error?) -> Void) {
    let managedModel = FritzManagedModel(modelConfig: modelConfig)

    managedModel.fetchModel { fritzModel, error in
      guard let fritzMLModel = fritzModel else {
        completionHandler(nil, error)
        return
      }

      do {
        let initializedModel = try Self(model: fritzMLModel)
        completionHandler(initializedModel, error)
      } catch {
        completionHandler(nil, error)
      }
    }
  }
}
