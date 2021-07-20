//
// poseLifter.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML

/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class poseLifterInput: MLFeatureProvider {

  /// keypoints2D as 2 element vector of doubles
  var keypoints2D: MLMultiArray

  var featureNames: Set<String> {
    return ["keypoints2D"]
  }

  func featureValue(for featureName: String) -> MLFeatureValue? {
    if featureName == "keypoints2D" {
      return MLFeatureValue(multiArray: keypoints2D)
    }
    return nil
  }

  init(keypoints2D: MLMultiArray) {
    self.keypoints2D = keypoints2D
  }
}

/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class poseLifterOutput: MLFeatureProvider {

  /// Source provided by CoreML
  private let provider: MLFeatureProvider

  /// keypoints3D as 3 element vector of doubles
  lazy var keypoints3D: MLMultiArray = {
    [unowned self] in return self.provider.featureValue(for: "keypoints3D")!.multiArrayValue
  }()!

  var featureNames: Set<String> {
    return self.provider.featureNames
  }

  func featureValue(for featureName: String) -> MLFeatureValue? {
    return self.provider.featureValue(for: featureName)
  }

  init(keypoints3D: MLMultiArray) {
    self.provider = try! MLDictionaryFeatureProvider(dictionary: [
      "keypoints3D": MLFeatureValue(multiArray: keypoints3D)
    ])
  }

  init(features: MLFeatureProvider) {
    self.provider = features
  }
}
