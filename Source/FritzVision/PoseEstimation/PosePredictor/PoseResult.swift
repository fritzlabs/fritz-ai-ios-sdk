import Foundation

@available(iOS 11.0, *)
public class FritzVisionPoseResult<Skeleton: SkeletonType>: FritzPredictionResult {

  /// Original input image before it was rescaled
  @objc public let image: FritzVisionImage

  /// Pose model options.
  @objc public let options: FritzVisionPoseModelOptions

  private let smootheFunc: (([Pose<Skeleton>]) -> [Pose<Skeleton>])?

  private let poseDecoder: DecodePoseWithDisplacements<Skeleton>?

  private let useDisplacements: Bool

  private let heatmap: MultiArray<Double>
  private let offsets: MultiArray<Double>
  private let modelInputSize: CGSize
  private let outputStride: Int

  internal init(
    for results: MLFeatureProvider,
    modelInputSize: CGSize,
    with fritzImage: FritzVisionImage,
    options: FritzVisionPoseModelOptions,
    outputStride: Int,
    smootheFunc: (([Pose<Skeleton>]) -> [Pose<Skeleton>])?,
    useDisplacements: Bool = false
  ) {
    self.modelInputSize = modelInputSize
    self.outputStride = outputStride
    if results.featureValue(for: "displacements_fwd") != nil, useDisplacements {
      self.poseDecoder
        = DecodePoseWithDisplacements<Skeleton>(
          for: results,
          modelInputSize: modelInputSize,
          outputStride: outputStride
        )
    } else {
      self.poseDecoder = nil
    }
    self.heatmap = MultiArray<Double>(results.featureValue(for: "heatmap")!.multiArrayValue!)
    self.offsets = MultiArray<Double>(results.featureValue(for: "offsets")!.multiArrayValue!)

    self.image = fritzImage
    self.options = options
    self.smootheFunc = smootheFunc
    self.useDisplacements = useDisplacements
  }

  internal init(
    heatmapScores: MLMultiArray,
    offsets: MLMultiArray,
    displacementsFwd: MLMultiArray?,
    displacementsBwd: MLMultiArray?,
    modelInputSize: CGSize,
    withImage fritzImage: FritzVisionImage,
    options: FritzVisionPoseModelOptions,
    outputStride: Int,
    smootheFunc: (([Pose<Skeleton>]) -> [Pose<Skeleton>])?,
    useDisplacements: Bool = false
  ) {
    self.modelInputSize = modelInputSize
    self.outputStride = outputStride
    if let displacementsFwd = displacementsFwd,
      let displacementsBwd = displacementsBwd,
      useDisplacements
    {
      self.poseDecoder
        = DecodePoseWithDisplacements<Skeleton>(
          heatmapScores: heatmapScores,
          offsets: offsets,
          displacementsFwd: displacementsFwd,
          displacementsBwd: displacementsBwd,
          modelInputSize: modelInputSize,
          outputStride: outputStride
        )
    } else {
      self.poseDecoder = nil
    }
    self.image = fritzImage
    self.options = options
    self.smootheFunc = smootheFunc
    self.heatmap = MultiArray<Double>(heatmapScores)
    self.offsets = MultiArray<Double>(offsets)
    self.useDisplacements = useDisplacements
  }
}

@available(iOS 11.0, *)
extension Pose {

  /// Returns true if any position has a NaN value
  var hasNaNPosition: Bool {
    keypoints.map { $0.position.x.isNaN || $0.position.y.isNaN }.reduce(false, { $0 || $1 })
  }
}

@available(iOS 11.0, *)
extension FritzVisionPoseResult {

  /// Get poses.
  ///
  /// - Parameter limit: Maximum number of poses to return.
  /// - Returns: List of Poses.
  public func poses(limit: Int = 5) -> [Pose<Skeleton>] {
    var poses: [Pose<Skeleton>]!
    if let poseDecoder = poseDecoder {
      poses
        = poseDecoder.decodeMultiplePoses(
          maxPoseDetections: limit,
          partThreshold: options.minPartThreshold,
          nmsRadius: options.nmsRadius
        ).filter { $0.score >= options.minPoseThreshold }
    } else {
      poses = [decodePose()]
    }

    poses = poses.filter { !$0.hasNaNPosition }

    if let smoother = smootheFunc {
      return smoother(poses).sorted { $0.score > $1.score }
    }
    return poses
  }

  /// Get single pose.
  public func pose() -> Pose<Skeleton>? {
    return self.poses(limit: 1).first
  }
}

@available(iOS 11.0, *)
extension FritzVisionPoseResult {

  func decodePose(scale: Bool = true) -> Pose<Skeleton> {

    let numKeypoints = Skeleton.allCases.count
    let gridHeight = heatmap.shape[1]
    let gridWidth = heatmap.shape[2]

    var keypoints = [Keypoint<Skeleton>]()

    for keypointIndex in 0..<numKeypoints {
      var max = 0.0
      var maxX = -1
      var maxY = -1
      for y in 0..<gridHeight {
        for x in 0..<gridWidth {
          let val = heatmap[keypointIndex, y, x]
          if val >= max {
            max = val
            maxX = x
            maxY = y
          }
        }
      }

      let dx = CGFloat(offsets[keypointIndex, maxY, maxX])
      let dy = CGFloat(offsets[keypointIndex + numKeypoints, maxY, maxX])

      let xScale = modelInputSize.width / CGFloat(gridWidth)
      let yScale = modelInputSize.height / CGFloat(gridHeight)
      let point = CGPoint(
        x: CGFloat(maxX) * xScale + dx,
        y: CGFloat(maxY) * yScale + dy
      )
      let keypoint = Keypoint<Skeleton>(
        index: keypointIndex,
        position: point,
        score: max,
        part: Skeleton(rawValue: keypointIndex)!
      )

      keypoints.append(keypoint)
    }

    return Pose<Skeleton>(keypoints: keypoints, score: 0.0, bounds: modelInputSize)
  }
}
