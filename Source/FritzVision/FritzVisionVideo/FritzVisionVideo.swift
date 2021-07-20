//
//  FritzVisionVideo.swift
//  FritzVision
//
//  Created by Steven Yeung on 10/25/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import AVFoundation
import Foundation
import Photos


@available(iOS 11.0, *)
public class FritzVisionVideo {

  /// The filters to apply on every frame of the video.
  /// - Note: filters are applied in chronological order.
  public let filters: [FritzVisionImageFilter]

  /// The video source.
  public let player: AVPlayer

  /// Factor to scale the frame rate.
  public var frameRateScale: Float = 1.0

  /// If the video should loop when previewing.
  public var loop = true

  /// The total length of the video in seconds.
  public var duration: TimeInterval {
    return playerItem.asset.duration.seconds
  }

  private var playerItem: AVPlayerItem {
    guard let playerItem = player.currentItem
      else { fatalError(FritzVisionVideoError.invalidVideo.message()) }
    return playerItem
  }

  /// Initializes with an AVPlayer.
  ///
  /// - Parameters:
  ///   - player: the video player
  ///   - filters: the filters to apply on the video
  public init(player: AVPlayer, applyingFilters filters: [FritzVisionImageFilter] = []) {
    self.filters = filters
    self.player = player
    playerItem.videoComposition = AVVideoComposition(
      asset: playerItem.asset,
      applyingFilters: filters
    )
  }

  public convenience init(player: AVPlayer, withFilter filter: FritzVisionImageFilter) {
    self.init(player: player, applyingFilters: [filter])
  }

  /// Initializes a video from an URL.
  /// URL can point to a file locally or online.
  ///
  /// - Parameters:
  ///   - url: location of the video
  ///   - filters: the filters to apply on the video
  public convenience init(url: URL, applyingFilters filters: [FritzVisionImageFilter] = []) {
    self.init(player: AVPlayer(url: url), applyingFilters: filters)
  }

  public convenience init(url: URL, withFilter filter: FritzVisionImageFilter) {
    self.init(url: url, applyingFilters: [filter])
  }

  /// Initializes a video from a file path.
  /// Path must conform to a URI file scheme.
  ///
  /// - Parameters:
  ///   - path: path to the video
  ///   - filters: the filters to apply on the video
  public convenience init(path: String, applyingFilters filters: [FritzVisionImageFilter] = []) {
    guard let videoURL = URL(string: path)
      else { fatalError(FritzVisionVideoError.invalidUrl.message()) }
    self.init(url: videoURL, applyingFilters: filters)
  }

  public convenience init(path: String, withFilter filter: FritzVisionImageFilter) {
    self.init(path: path, applyingFilters: [filter])
  }

  /// Appends video content to the current video.
  ///
  /// - Parameters:
  ///   - asset: the video content to append
  public func stitch(with asset: AVAsset) throws {
    guard let pair = try? mutableAsset(),
      let composition = pair.composition,
      let compositionTrack = pair.track,
      let track = asset.tracks(withMediaType: .video).first
      else { return }

    do {
      try compositionTrack.insertTimeRange(
        CMTimeRangeMake(start: .zero, duration: asset.duration),
        of: track,
        at: composition.duration
      )
    } catch let error {
      throw error
    }

    let item = AVPlayerItem(asset: composition)
    item.videoComposition = AVVideoComposition(asset: composition, applyingFilters: filters)
    player.replaceCurrentItem(with: item)
  }
}

@available(iOS 11.0, *)
extension FritzVisionVideo {

  private typealias CompositionPair = (
    composition: AVMutableComposition?, track: AVMutableCompositionTrack?
  )

  /// Creates a mutable video.
  private func mutableAsset() throws -> CompositionPair {
    let baseAsset = playerItem.asset
    let composition = AVMutableComposition()
    guard let baseTrack = baseAsset.tracks(withMediaType: AVMediaType.video).first,
      let compositionTrack = composition.addMutableTrack(
        withMediaType: AVMediaType.video,
        preferredTrackID: CMPersistentTrackID()
      )
      else { return (nil, nil) }

    // Attempt to write the contents of the current video to the composition
    do {
      try compositionTrack.insertTimeRange(
        CMTimeRangeMake(start: .zero, duration: baseAsset.duration),
        of: baseTrack,
        at: .zero
      )
    } catch let error {
      throw error
    }

    compositionTrack.preferredTransform = baseTrack.preferredTransform
    return (composition, compositionTrack)
  }
}

@available(iOS 11.0, *)
extension FritzVisionVideo {

  public typealias ExportCompletionHandler = (Result<URL, FritzVisionVideoError>) -> Void

  /// Exports a video to the Camera Roll.
  ///
  /// - Parameters:
  ///   - url: path to the video
  ///   - fileType: output file type for the video
  ///   - preset: quality to export the video
  ///   - exportDidComplete: handler to be called upon a completed export attempt
  /// - Returns: the export session in order to track progress
  @discardableResult
  public func export(
    to url: URL,
    as fileType: AVFileType,
    with preset: String = AVAssetExportPresetMediumQuality,
    onExportComplete: @escaping ExportCompletionHandler
  ) -> AVAssetExportSession? {
    guard let pair = try? mutableAsset(),
      let composition = pair.composition,
      let compositionTrack = pair.track
      else {
        onExportComplete(.failure(FritzVisionVideoError.invalidExportSession))
        return nil
    }

    // Setting the framerate
    let videoDuration = composition.duration
    let totalTime = Int64(Float(videoDuration.value) / frameRateScale)
    compositionTrack.scaleTimeRange(
      CMTimeRangeMake(start: .zero, duration: videoDuration),
      toDuration: CMTimeMake(value: totalTime, timescale: videoDuration.timescale)
    )

    guard let export = AVAssetExportSession(asset: composition, presetName: preset) else {
      onExportComplete(.failure(FritzVisionVideoError.invalidExportSession))
      return nil
    }

    export.outputURL = url
    export.outputFileType = fileType
    export.videoComposition = AVVideoComposition(asset: composition, applyingFilters: filters)
    export.exportAsynchronously {
      PHPhotoLibrary.requestAuthorization { status in
        if status == .authorized {
          PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
          }) { saved, _ in
            if saved {
              onExportComplete(.success(url))
              return
            }
            onExportComplete(.failure(FritzVisionVideoError.incompleteExport))
          }
        } else {
          onExportComplete(.failure(FritzVisionVideoError.unauthorizedExport))
        }
      }
    }
    return export
  }
}

@available(iOS 11.0, *)
extension FritzVisionVideo {

  public typealias FrameExtractionCompletionHandler = (
    Result<FritzVisionImage, FritzVisionVideoError>
    ) -> Void

  /// Get a frame of the video at the specified time.
  ///
  /// - Parameters:
  ///   - time: timestamp to retrieve the frame in seconds
  ///   - processed: if the frame should be processed
  /// - Returns: the image at the specified time, if it exists
  public func frame(at time: TimeInterval, processed: Bool = true) -> FritzVisionImage? {
    let imageGenerator = AVAssetImageGenerator(asset: playerItem.asset)
    if processed {
      imageGenerator.videoComposition = playerItem.videoComposition
    }
    guard
      let frame = try? imageGenerator.copyCGImage(
        at: CMTime(seconds: time, preferredTimescale: TimeFormat.scale),
        actualTime: nil
      )
      else { return nil }
    return FritzVisionImage(image: UIImage(cgImage: frame))
  }

  /// Asynchronously get frames of the video, one a a time, for the specified times.
  /// Use when extracting multiple frames to prevent blocking the main thread.
  /// Handler is called upon each frame extraction.
  ///
  /// - Parameters:
  ///   - times: timestamps to retrieve the frames in seconds
  ///   - processed: if the frames should be processed
  ///   - extractDidComplete: handler to perform upon a frame extraction
  public func frames(
    at times: [TimeInterval],
    processed: Bool = true,
    onExtractionComplete: @escaping FrameExtractionCompletionHandler
  ) {
    let imageGenerator = AVAssetImageGenerator(asset: playerItem.asset)
    if processed {
      imageGenerator.videoComposition = playerItem.videoComposition
    }
    let formattedTimes = times.map {
      NSValue(time: CMTime(seconds: $0, preferredTimescale: TimeFormat.scale))
    }
    imageGenerator.generateCGImagesAsynchronously(
      forTimes: formattedTimes
    ) { _, image, _, result, _ in
      if result == .succeeded, let image = image {
        let fritzImage = FritzVisionImage(image: UIImage(cgImage: image))
        onExtractionComplete(.success(fritzImage))
        return
      }
      onExtractionComplete(.failure(FritzVisionVideoError.incompleteExtraction))
    }
  }
}

struct TimeFormat {

  /// Common multiple of standard framerates.
  /// Use as a timescale for precise timings.
  static var scale: Int32 = 600
}

public enum FritzVisionVideoError: Error {
  case invalidVideo
  case invalidUrl
  case invalidExportSession
  case invalidPrediction
  case incompleteExport
  case incompleteExtraction
  case unauthorizedExport

  public func message() -> String {
    switch self {
    case .invalidVideo:
      return """
      Unable to load video.
      Please ensure that the video has an associated AVPlayerItem.
      """
    case .invalidUrl:
      return """
      Unable to load video.
      Please ensure that the URL to the video is valid.
      """
    case .invalidExportSession:
      return """
      Unable to create export session.
      Please ensure that you are using a valid preset: \(AVAssetExportSession.allExportPresets())
      """
    case .invalidPrediction:
      return """
      Unable to apply prediction filters.
      Please ensure that valid filters are being applied.
      """
    case .incompleteExport:
      return """
      Error with exporting video.
      Please ensure that you are using a valid output path.
      """
    case .incompleteExtraction:
      return """
      Error with extracting frame.
      Please ensure that you are extracting frames within the duration of the video.
      """
    case .unauthorizedExport:
      return """
      Unable to export video.
      Please ensure that you have permission to save to the photo library.
      """
    }
  }
}
