//
//  MLFeatureProvider+Helpers.swift
//  CoreMLHelpers
//
//  Created by Christopher Kelly on 3/27/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import CoreML
import Foundation

@available(iOS 11.0, *)
extension MLFeatureProvider {

  /// Returns feature value for first output feature.
  public var first: MLFeatureValue? {
    if let firstFeatureName = featureNames.first {
      return featureValue(for: firstFeatureName)
    }
    return nil
  }
}
