//
//  FritzPredictorProtocols+ModelTags.swift
//  FritzVision
//
//  Created by Christopher Kelly on 2/6/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public enum FritzVisionModelTagError: Error {
  case loadingModelsFailed(errors: [Error])
  case noModelReturned
}

@available(iOS 11.0, *)
extension FritzMLModelInitializable {

  /// Fetch and load Style Models for the given tags.
  ///
  /// Note that this instantiates all models which could cause memory pressure if you are loading many models.
  /// If you do not want to immediately instantiate the models, create a ModelTagManager and manage loading yourself.
  ///
  /// - Parameters:
  ///   - tags: List of tags to load models for.
  ///   - wifiRequiredForModelDownload: True if client must be on WiFi to download model. Default is false.
  ///   - completionHandler: Completion handler with instantiated FritzVisionStyleModels
  static func _fetchModelsForTags(
    tags: [String],
    wifiRequiredForModelDownload: Bool = false,
    completionHandler: @escaping ([FritzMLModelInitializable]?, Error?) -> Void
  ) {
    let tagManager = ModelTagManager(tags: tags)
    tagManager.fetchManagedModelsForTags(
      wifiRequiredForModelDownload: wifiRequiredForModelDownload
    ) { models, error in
      guard let managedModels = models else {
        completionHandler(nil, error)
        return
      }

      var initializedModels: [FritzMLModelInitializable] = []
      var errors: [Error] = []

      for managedModel in managedModels {
        managedModel.fetchModel() { mlmodel, error in
          guard let fritzMLModel = mlmodel, error == nil else {
            errors.append(error ?? FritzVisionModelTagError.noModelReturned)
            return
          }
          do {
            initializedModels.append(try Self(model: fritzMLModel))
          } catch {
            errors.append(error)
          }

          if initializedModels.count + errors.count == managedModels.count {
            if errors.count > 0 {
              completionHandler(
                initializedModels,
                FritzVisionModelTagError.loadingModelsFailed(errors: errors)
              )
            } else {
              completionHandler(initializedModels, nil)
            }
          }
        }
      }
    }
  }
}
