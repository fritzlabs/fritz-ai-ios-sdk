//
//  DecodePose.swift
//  FritzVision
//
//  Created by Christopher Kelly on 2/4/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

func clamp(_ a: Int, min: Int, max: Int) -> Int {
  if a < min { return min }
  if a > max { return max }
  return a
}

extension HeatmapPoint {
  static func + (left: HeatmapPoint, right: HeatmapPoint) -> HeatmapPoint {
    return HeatmapPoint(x: left.x + right.x, y: left.y + right.y)
  }

  static func + (left: HeatmapPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: CGFloat(left.x) + right.x, y: CGFloat(left.y) + right.y)
  }
}

@available(iOS 11.0, *)
func getDisplacement(edgeID: Int, point: HeatmapPoint, displacements: Displacements) -> CGPoint {
  let displacementX = displacements[point, edgeID, .x]
  let displacementY = displacements[point, edgeID, .y]
  return CGPoint(x: displacementX, y: displacementY)
}

@available(iOS 11.0, *)
func scoreIsMaxInLocalWindow(
  xIdx: Int,
  yIdx: Int,
  kIdx: Int,
  score: Double,
  scores: HeatmapScores,
  localMaxRadius: Int
) -> Bool {

  let height = scores.height
  let width = scores.width

  let yStart = max(yIdx - localMaxRadius, 0)
  let yEnd = min(yIdx + localMaxRadius, height)
  let xStart = max(xIdx - localMaxRadius, 0)
  let xEnd = min(xIdx + localMaxRadius, width)

  for yNbr in yStart..<yEnd {
    for xNbr in xStart..<xEnd {
      if scores[yNbr, xNbr, kIdx] > score {
        return false
      }
    }
  }

  return true
}

typealias PartWithScore = (score: Double, part: Part)

@available(iOS 11.0, *)
public class DecodePoseWithDisplacements<Skeleton: SkeletonType> {

  let outputStride: Int
  let scores: HeatmapScores
  let offsets: Offsets
  let displacementsFwd: Displacements
  let displacementsBwd: Displacements
  let modelInputSize: CGSize

  var outputRatio: CGSize {
    // TODO: Not thrilled about this, but the dimensions of the pose model
    // are made to work with the output stride hard coded. When using the ratio
    // of input size to output size, it is not quite the right value.
    // with the 353x257 model, (x-1) / (grid width - 1) gives you the correct output
    // stride. I think the model is trained to accommodate this.
    // let xScale = modelInputSize.width / CGFloat(scores.width)
    // let yScale = modelInputSize.height / CGFloat(scores.height)
    // return CGSize(width: xScale, height: yScale)
    return CGSize(width: outputStride, height: outputStride)
  }

  init(for results: MLFeatureProvider, modelInputSize: CGSize, outputStride: Int) {
    self.scores = HeatmapScores(for: results.featureValue(for: "heatmap")!.multiArrayValue)
    self.offsets = Offsets(for: results.featureValue(for: "offsets")!.multiArrayValue)
    self.displacementsFwd
      = Displacements(for: results.featureValue(for: "displacements_fwd")!.multiArrayValue)
    self.displacementsBwd
      = Displacements(for: results.featureValue(for: "displacements_bwd")!.multiArrayValue)
    self.modelInputSize = modelInputSize
    self.outputStride = outputStride
  }

  init(
    heatmapScores: MLMultiArray,
    offsets: MLMultiArray,
    displacementsFwd: MLMultiArray,
    displacementsBwd: MLMultiArray,
    modelInputSize: CGSize,
    outputStride: Int
  ) {
    self.scores = HeatmapScores(for: heatmapScores)
    self.offsets = Offsets(for: offsets)
    self.displacementsFwd = Displacements(for: displacementsFwd)
    self.displacementsBwd = Displacements(for: displacementsBwd)
    self.modelInputSize = modelInputSize
    self.outputStride = outputStride
  }

  /// Decodes poses from model output. Returns poses with keypoint positions normalized from 0 to 1.
  /// - Parameter maxPoseDetections: Number of poses to detect.
  /// - Parameter partThreshold: Threshold for a part to be included in a pose.
  /// - Parameter nmsRadius: NMS radius.
  public func decodeMultiplePoses(
    maxPoseDetections: Int,
    partThreshold: Double = 0.5,
    nmsRadius: Int = 20
  ) -> [Pose<Skeleton>] {
    var poses: [Pose<Skeleton>] = []

    var queue = buildPartWithScoreQueue(partThreshold: partThreshold, localMaxRadius: 1)
    let squaredNMSRadius = nmsRadius * nmsRadius
    while poses.count < maxPoseDetections, !queue.isEmpty {
      guard let root = queue.dequeue() else {
        continue
      }

      let rootImgCoords = getImageCoordinates(part: root.part)
      if withinNMSRadiusOfCorrespondingPoint(
        poses: poses,
        squaredNMSRadius: Double(squaredNMSRadius),
        point: rootImgCoords,
        keypointID: root.part.id
      ) {
        continue
      }

      let keypoints = decodePose(root: root)
      let score = getInstanceScore(
        existingPoses: poses,
        squaredNMSRadius: Double(squaredNMSRadius),
        instanceKeypoints: keypoints
      )

      poses.append(Pose(keypoints: keypoints, score: score, bounds: modelInputSize))
    }

    return poses.map { $0.scaled(to: CGSize(width: 1, height: 1)) }
  }

  func getStridedIndexNearPoint(point: CGPoint, height: Int, width: Int) -> HeatmapPoint {

    let roundedY = Int((point.y / outputRatio.height).rounded())
    let roundedX = Int((point.x / outputRatio.width).rounded())
    // some weird typing going on here, check its correct later
    return HeatmapPoint(
      x: clamp(roundedX, min: 0, max: width - 1),
      y: clamp(roundedY, min: 0, max: height - 1)
    )
  }

  func getOffsetPoint(point: HeatmapPoint, keypointID: Int) -> CGPoint {
    let x = offsets.get(y: point.y, x: point.x, partID: keypointID, offset: .x)
    let y = offsets.get(y: point.y, x: point.x, partID: keypointID, offset: .y)
    return CGPoint(x: x, y: y)
  }

  func traverseToTargetKeypoint(
    displacements: Displacements,
    edgeID: Int,
    sourceKeypoint: Keypoint<Skeleton>,
    targetKeypointID: Int
  ) -> Keypoint<Skeleton> {
    let height = scores.height
    let width = scores.width

    let sourceKeypointIndices = getStridedIndexNearPoint(
      point: sourceKeypoint.position,
      height: height,
      width: width
    )
    let part = Skeleton(rawValue: targetKeypointID)!
    let displacement = getDisplacement(
      edgeID: edgeID,
      point: sourceKeypointIndices,
      displacements: displacements
    )
    let displacedPoint = sourceKeypoint.position + displacement

    let displacedPointIndices = getStridedIndexNearPoint(
      point: displacedPoint,
      height: height,
      width: width
    )

    let offsetPoint = getOffsetPoint(point: displacedPointIndices, keypointID: targetKeypointID)

    let score = scores[displacedPointIndices, targetKeypointID]
    let targetKeypoint
      = CGPoint(
        x: CGFloat(displacedPointIndices.x) * outputRatio.width,
        y: CGFloat(displacedPointIndices.y) * outputRatio.height
      ) + offsetPoint

    return Keypoint(index: targetKeypointID, position: targetKeypoint, score: score, part: part)
  }

  /// Decodes pose from root part. Returns List of keypoints with coordinates normalized from 0 to 1.
  /// - Parameter root: Root body part.
  private func decodePose(root: PartWithScore) -> [Keypoint<Skeleton>] {
    let numParts = scores.numKeypoints
    let numEdges = Skeleton.parentToChildEdges.count
    var instanceKeypoints: [Keypoint<Skeleton>?] = Array(repeating: nil, count: numParts)

    let rootPart = root.part
    let rootScore = root.score

    let rootPoint = getImageCoordinates(part: rootPart)
    instanceKeypoints[rootPart.id]
      = Keypoint<Skeleton>(
        index: rootPart.id,
        position: rootPoint,
        score: rootScore,
        part: Skeleton(rawValue: rootPart.id)!
      )

    for edge in (0...(numEdges - 1)).reversed() {
      let sourceKeypointID = Skeleton.parentToChildEdges[edge].rawValue
      let targetKeypointID = Skeleton.childToParentEdges[edge].rawValue
      if let sourceKeypoint = instanceKeypoints[sourceKeypointID],
        instanceKeypoints[targetKeypointID] == nil
      {
        let newKeypoint = traverseToTargetKeypoint(
          displacements: displacementsBwd,
          edgeID: edge,
          sourceKeypoint: sourceKeypoint,
          targetKeypointID: targetKeypointID
        )
        instanceKeypoints[targetKeypointID] = newKeypoint
      }
    }

    for edge in 0..<numEdges {
      let sourceKeypointID = Skeleton.childToParentEdges[edge].rawValue
      let targetKeypointID = Skeleton.parentToChildEdges[edge].rawValue
      if let sourceKeypoint = instanceKeypoints[sourceKeypointID],
        instanceKeypoints[targetKeypointID] == nil
      {
        instanceKeypoints[targetKeypointID]
          = traverseToTargetKeypoint(
            displacements: displacementsFwd,
            edgeID: edge,
            sourceKeypoint: sourceKeypoint,
            targetKeypointID: targetKeypointID
          )
      }
    }
    return instanceKeypoints.map { $0! }
  }

  func buildPartWithScoreQueue(partThreshold: Double, localMaxRadius: Int) -> PriorityQueue<
    PartWithScore
  > {
    let height = scores.height
    let width = scores.width
    let numKeypoints = scores.numKeypoints

    var priorityQueue = PriorityQueue<PartWithScore>(sort: { part1, part2 in
      if part1.score > part2.score {
        return true
      } else {
        return false
      }
    })

    for yIdx in 0..<height {
      for xIdx in 0..<width {
        for kIdx in 0..<numKeypoints {
          let score = scores[yIdx, xIdx, kIdx]
          if score < partThreshold {
            continue
          }
          if scoreIsMaxInLocalWindow(
            xIdx: xIdx,
            yIdx: yIdx,
            kIdx: kIdx,
            score: score,
            scores: scores,
            localMaxRadius: localMaxRadius
          ) {
            let part = Part(x: xIdx, y: yIdx, keypointID: kIdx)
            priorityQueue.enqueue((score: score, part: part))
          }
        }
      }
    }
    return priorityQueue
  }

  func getImageCoordinates(part: Part) -> CGPoint {
    let dx = offsets.get(y: part.heatmapY, x: part.heatmapX, partID: part.id, offset: .x)
    let dy = offsets.get(y: part.heatmapY, x: part.heatmapX, partID: part.id, offset: .y)
    return CGPoint(
      x: CGFloat(Double(CGFloat(part.heatmapX) * outputRatio.width) + dx),
      y: CGFloat(Double(CGFloat(part.heatmapY) * outputRatio.height) + dy)
    )
  }

  func withinNMSRadiusOfCorrespondingPoint(
    poses: [Pose<Skeleton>],
    squaredNMSRadius: Double,
    point: CGPoint,
    keypointID: Int
  ) -> Bool {
    let squaredDistances = poses.map { (pose: Pose<Skeleton>) -> CGFloat in
      let distance = pose.keypoints[keypointID].position.squaredDistance(point)
      return distance
    }

    return squaredDistances.filter { $0 <= CGFloat(squaredNMSRadius) }.count > 0
  }

  func getInstanceScore(
    existingPoses: [Pose<Skeleton>],
    squaredNMSRadius: Double,
    instanceKeypoints: [Keypoint<Skeleton>]
  ) -> Double {
    let notOverlappedKeypointScores = instanceKeypoints.reduce(
      Double(0.0),
      { result, keypoint in
        if withinNMSRadiusOfCorrespondingPoint(
          poses: existingPoses,
          squaredNMSRadius:
            squaredNMSRadius,
          point: keypoint.position,
          keypointID: keypoint.index
        ) != true {
          return result + keypoint.score
        } else {
          return result
        }
      }
    )

    return notOverlappedKeypointScores / Double(instanceKeypoints.count)
  }
}
