//
//  FritzVideoView.swift
//  FritzVision
//
//  Created by Steven Yeung on 10/27/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

@available(iOS 11.0, *)
open class FritzVideoView: UIView {

  /// The video to play and apply filters on.
  /// Prepares view for playback upon setting.
  public var fritzVideo: FritzVisionVideo? = nil {
    willSet { tearDown() }
    didSet { prepare() }
  }

  public var isPlaying: Bool {
    guard let fritzVideo = fritzVideo else { return false }
    return fritzVideo.player.rate > 0
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  /// Initialize as an empty view.
  public init() {
    super.init(frame: .zero)
  }

  /// Initializes with an existing FritzVisionVideo.
  ///
  /// - Parameters:
  ///   - source: the video to preview.
  public init(source: FritzVisionVideo) {
    super.init(frame: .zero)
    self.fritzVideo = source
  }

  /// Plays the video using configured video options.
  public func play() {
    guard let fritzVideo = fritzVideo else { return }
    fritzVideo.player.play()
    fritzVideo.player.rate = fritzVideo.frameRateScale
  }

  /// Pauses the video.
  public func pause() {
    guard let fritzVideo = fritzVideo else { return }
    fritzVideo.player.pause()
  }

  /// Stops the video and removes all components of the view.
  public func stop() {
    self.fritzVideo = nil
  }

  /// Seeks to the desired time of the video.
  ///
  /// - Parameters:
  ///   - time: the time to seek to
  public func seek(to time: TimeInterval) {
    guard let fritzVideo = fritzVideo else { return }
    if time >= 0, time <= fritzVideo.duration {
      let player = fritzVideo.player
      player.seek(
        to: CMTime(seconds: time, preferredTimescale: TimeFormat.scale),
        toleranceBefore: .zero,
        toleranceAfter: .zero
      )
    }
  }

  /// Prepares the view to play video.
  /// Sets listener for completed playback in order to loop.
  private func prepare() {
    guard let fritzVideo = fritzVideo else { return }
    let player = fritzVideo.player
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.frame = self.bounds
    layer.addSublayer(playerLayer)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(itemDidPlayToEndTime),
      name: .AVPlayerItemDidPlayToEndTime,
      object: player.currentItem
    )
  }

  /// Pauses and removes the video from the view.
  private func tearDown() {
    guard let fritzVideo = fritzVideo else { return }
    pause()
    NotificationCenter.default.removeObserver(
      self,
      name: .AVPlayerItemDidPlayToEndTime,
      object: fritzVideo.player.currentItem
    )
    layer.sublayers?.forEach { $0.removeFromSuperlayer() }
  }
}

@available(iOS 11.0, *)
extension FritzVideoView {

  /// Plays the video back from start.
  @objc private func itemDidPlayToEndTime(_ notification: Notification) {
    if let fritzVideo = fritzVideo, fritzVideo.loop {
      seek(to: .zero)
      play()
    }
  }
}
