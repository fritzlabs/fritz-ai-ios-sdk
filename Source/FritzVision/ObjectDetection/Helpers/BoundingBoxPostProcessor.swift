//
//  BoundingBoxPostProcessor.swift
//  AllFritzTests
//
//  Created by Steven Yeung on 10/8/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import CoreML
import Foundation
import UIKit

@available(iOS 11.0, *)
class BoundingBoxPostProcessor: PostProcessor {
  let classNames: [String]

  init(classNames: [String]) {
    self.classNames = classNames
  }

  func postProcess(
    boxPredictions: MLMultiArray,
    classPredictions: MLMultiArray,
    options: FritzVisionObjectModelOptions
  ) -> [Prediction] {
    let boxPredictions = extractBoxes(
      boxPredictions: boxPredictions,
      classPredictions: classPredictions,
      maxBoxes: options.numResults
    )
    return boxPredictions.filter { $0.score >= options.threshold } .sorted { $0.score > $1.score }
  }

  private func extractBoxes(
    boxPredictions: MLMultiArray,
    classPredictions: MLMultiArray,
    maxBoxes: Int
  ) -> [Prediction] {
    var predictedObjects: [Prediction] = []
    let numBoundingBoxes = min(classPredictions.shape[0].intValue, maxBoxes)
    let numClasses = classPredictions.shape[1].intValue
    let classPredictionsPointer = UnsafeMutablePointer<Double>(
      OpaquePointer(classPredictions.dataPointer)
    )
    let boxPredictionsPointer = UnsafeMutablePointer<Double>(
      OpaquePointer(boxPredictions.dataPointer)
    )

    // Extract the objects encased by each bounding box
    for boxCount in 0..<numBoundingBoxes {
      var maxConfidence = 0.0
      var maxIndex = -1

      for classCount in 0..<numClasses {
        let conf = classPredictionsPointer[offset(boxCount, classCount, strides: numClasses)]

        if conf > maxConfidence {
          maxConfidence = conf
          maxIndex = classCount
        }
      }
      
      // If we still haven't set the maxIndex, it's not a valid object
      // and there is no need to keep going.
      if (maxIndex < 0) {
        continue
      }

      let x = boxPredictionsPointer[offset(boxCount, 0, strides: 4)]
      let y = boxPredictionsPointer[offset(boxCount, 1, strides: 4)]
      let w = boxPredictionsPointer[offset(boxCount, 2, strides: 4)]
      let h = boxPredictionsPointer[offset(boxCount, 3, strides: 4)]

      let rect = CGRect(
        x: CGFloat(x - w / 2),
        y: CGFloat(y - h / 2),
        width: CGFloat(w),
        height: CGFloat(h)
      )

      let prediction = Prediction(
        index: boxCount,
        score: maxConfidence,
        boundingBox: rect,
        detectedClassLabel: classNames[maxIndex]
      )
      predictedObjects.append(prediction)
    }
    return predictedObjects
  }
}
