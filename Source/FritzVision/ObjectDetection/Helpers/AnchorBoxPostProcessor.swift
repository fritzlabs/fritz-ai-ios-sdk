import Accelerate
// Copyright (c) 2017 M.I. Hollemans
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
import CoreML
import UIKit

struct AnchorEncoding {
  let ty: Double
  let tx: Double
  let th: Double
  let tw: Double
}

struct AnchorBox {
  let Y_SCALE = 10.0
  let X_SCALE = 10.0
  let H_SCALE = 5.0
  let W_SCALE = 5.0
  let anchor: Anchor
  let anchorEncoding: AnchorEncoding

  var transformedBox: BoundingBox {
    let yCenter = anchorEncoding.ty / Y_SCALE * anchor.height + anchor.yCenter
    let xCenter = anchorEncoding.tx / X_SCALE * anchor.width + anchor.xCenter
    let h = exp(anchorEncoding.th / H_SCALE) * anchor.height
    let w = exp(anchorEncoding.tw / W_SCALE) * anchor.width

    let yMin = yCenter - h / 2.0
    let xMin = xCenter - w / 2.0
    let yMax = yCenter + h / 2.0
    let xMax = xCenter + w / 2.0

    return BoundingBox(yMin: yMin, xMin: xMin, yMax: yMax, xMax: xMax)
  }
}

@available(iOS 11.0, *)
class AnchorBoxPostProcessor: PostProcessor {
  let numAnchors: Int = 1917
  let numClasses: Int
  let imageHeight: Double
  let imageWidth: Double

  let classNames: [String]

  init(imageHeight: Double, imageWidth: Double, classNames: [String]) {
    self.imageWidth = imageWidth
    self.imageHeight = imageHeight
    self.classNames = classNames
    self.numClasses = classNames.count
  }

  func postProcess(
    boxPredictions: MLMultiArray,
    classPredictions: MLMultiArray,
    options: FritzVisionObjectModelOptions
  ) -> [Prediction] {
    let prunedPredictions = pruneLowScoring(
      boxPredictions: boxPredictions,
      classPredictions: classPredictions,
      threshold: options.threshold
    )
    let finalPredictions = nonMaximumSupression(
      predictions: prunedPredictions,
      iouThreshold: options.iouThreshold,
      maxBoxes: options.numResults
    )
    if finalPredictions.count < options.numResults {
      return finalPredictions
    }
    return Array(finalPredictions[0 ..< options.numResults])
  }

  private func nonMaximumSupression(
    predictions: [[Prediction]],
    iouThreshold: Double,
    maxBoxes: Int
  ) -> [Prediction] {
    var finalPredictions: [Prediction] = []

    for klass in 1...numClasses {
      let predictionsForClass = predictions[klass]

      let supressedPredictions = nonMaximumSupressionForClass(
        predictions: predictionsForClass,
        iouThreshold: iouThreshold,
        maxBoxes: maxBoxes
      )
      finalPredictions.append(contentsOf: supressedPredictions)
    }

    return finalPredictions.sorted(by: { return $0.score > $1.score })
  }

  /// Removes similar, overlapping predictions.
  ///
  /// - Parameters:
  ///   - predictions: The predictions to process
  ///   - iouThreshold: The allowed threshold in which boxes can overlap
  ///   - maxBoxes: The maximum amuont of boxes allowed
  /// - Returns: Unique predictions found
  func nonMaximumSupressionForClass(
    predictions: [Prediction],
    iouThreshold: Double,
    maxBoxes: Int? = nil
  ) -> [Prediction] {
    var validPredictions: [Prediction] = []

    // Sort the boxes based on their confidence scores, from high to low.
    let sortedPredictions = predictions.sorted { $0.score > $1.score }

    // Loop through the predictions, from highest score to lowest score,
    // and determine whether or not to keep each box.
    for prediction in sortedPredictions {
      if let maxBoxes = maxBoxes, validPredictions.count >= maxBoxes { break }
      var shouldSelect = true

      // Does the current box overlap one of the selected boxes more than the
      // given threshold amount? Then it's too similar, so don't keep it.
      for box in validPredictions {
        if IOU(prediction.boundingBox, box.boundingBox) > iouThreshold {
          shouldSelect = false
          break
        }
      }

      // This bounding box did not overlap too much with any previously selected
      // bounding box, so we'll keep it.
      if shouldSelect {
        validPredictions.append(prediction)
      }
    }
    return predictions
  }

  /// Computes intersection-over-union overlap between two bounding boxes.
  ///
  /// - Parameters:
  ///   - a: First bounding box
  ///   - b: Second bounding box
  /// - Returns: IOU overlap value
  func IOU(_ a: CGRect, _ b: CGRect) -> Double {
    let areaA = a.width * a.height
    if areaA <= 0 { return 0 }

    let areaB = b.width * b.height
    if areaB <= 0 { return 0 }

    let intersectionMinX = max(a.minX, b.minX)
    let intersectionMinY = max(a.minY, b.minY)
    let intersectionMaxX = min(a.maxX, b.maxX)
    let intersectionMaxY = min(a.maxY, b.maxY)
    let intersectionArea = max(intersectionMaxY - intersectionMinY, 0)
      * max(intersectionMaxX - intersectionMinX, 0)
    return Double(intersectionArea / (areaA + areaB - intersectionArea))
  }

  private func sigmoid(_ val: Double) -> Double {
    return 1.0 / (1.0 + exp(-val))
  }

  private func pruneLowScoring(
    boxPredictions: MLMultiArray,
    classPredictions: MLMultiArray,
    threshold: Double
  ) -> [[Prediction]] {
    var prunedPredictionsByClass: [[Prediction]] = Array(repeating: [], count: numClasses + 1)

    let classpreds = MultiArray<Double>(classPredictions)
    var modifiedClassPredictions = Array(
      UnsafeBufferPointer(
        start: classpreds.pointer,
        count: classpreds.count
      )
    )
    Math.sigmoid(&modifiedClassPredictions, modifiedClassPredictions.count)

    for boxIdx in 0..<numAnchors {
      var maxScore = 0.0
      var maxIndex = -1

      for classIdx in 1...numClasses {
        let score = modifiedClassPredictions[offset(classIdx, boxIdx)]
        if score < threshold {
          continue
        }
        if score >= maxScore {
          maxScore = score
          maxIndex = classIdx
        }
      }

      if maxIndex == -1 {
        continue
      }

      let classLabel = classNames[maxIndex - 1]
      let anchorEncoding = AnchorEncoding(
        ty: boxPredictions[offset(0, boxIdx)].doubleValue,
        tx: boxPredictions[offset(1, boxIdx)].doubleValue,
        th: boxPredictions[offset(2, boxIdx)].doubleValue,
        tw: boxPredictions[offset(3, boxIdx)].doubleValue
      )

      let preBox = AnchorBox(
        anchor: Anchors.ssdAnchors[boxIdx],
        anchorEncoding: anchorEncoding
      ).transformedBox

      let prediction = Prediction(
        index: boxIdx,
        score: maxScore,
        boundingBox: preBox.toCGRect(
          imgHeight: imageHeight,
          imgWidth: imageWidth
        ),
        detectedClassLabel: classLabel
      )
      prunedPredictionsByClass[maxIndex].append(prediction)
    }
    return prunedPredictionsByClass
  }

  private func offset(_ i: Int, _ j: Int) -> Int {
    return offset(i, j, strides: numAnchors)
  }
}
