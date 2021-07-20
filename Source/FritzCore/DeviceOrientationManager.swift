//
//  DeviceOrientationManager.swift
//  Fritz
//
//  Created by Christopher Kelly on 7/26/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Tracks Device Orientation changes.
@objc(DeviceOrientationManager)
public class DeviceOrientationManager: NSObject {

  /// Current device orientation.
  public private(set) var orientation: UIDeviceOrientation

  public override init() {
    self.orientation = UIDevice.current.orientation
    super.init()
    beginTrackingDeviceOrientation()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func beginTrackingDeviceOrientation() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleOrientationChangedNotification),
      name: UIDevice.orientationDidChangeNotification,
      object: nil
    )
    if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
      UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
  }

  @objc
  func handleOrientationChangedNotification(_ notification: Notification) {
    orientation = UIDevice.current.orientation
  }
}
