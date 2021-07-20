//
//  PostProcessor.swift
//  Fritz
//
//  Created by Steven Yeung on 10/9/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

struct Prediction {
  let index: Int
  let score: Double
  let boundingBox: CGRect
  let detectedClassLabel: String
}

@available(iOS 11.0, *)
protocol PostProcessor {

  /// Determines box coordinates and confidence scores for images.
  /// Pruning can be done by the model itself or as an extra processing step.
  ///
  /// - Parameters:
  ///   - boxPredictions: coordinates of the bounding boxes for each detected object
  ///   - classPredictions: matrix of confidence scores for each class name
  func postProcess(
    boxPredictions: MLMultiArray,
    classPredictions: MLMultiArray,
    options: FritzVisionObjectModelOptions
  ) -> [Prediction]
}

@available(iOS 11.0, *)
extension PostProcessor {

  /// Calculates the proper index of an element in a matrix.
  ///
  /// - Parameters:
  ///   - i: row position
  ///   - j: column position
  ///   - strides: number of elements to step in
  func offset(_ i: Int, _ j: Int, strides: Int) -> Int {
    return i * strides + j
  }
}
