//
//  Notifications.swift
//  Fritz
//
//  Created by Andrew Barba on 11/10/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

extension NSNotification {

  /// Subscribe to this notification to receive Fritz-related errors
  @objc(FritzErrorNotificationKey)
  public static let errorNotificationKey = "com.fritz.sdk.notifications.error"

  /// Subscribe to this notification to know when a Fritz model has been updated
  @objc(FritzModelUpdatedNotificationKey)
  public static let modelUpdatedNotificationKey = "com.fritz.sdk.notifications.model-updated"

  /// Subscribe to this notification to know when a Fritz activeModel has changed
  @objc(FritzModelActiveModelChangedNotificationKey)
  public static let activeModelChangedNotificationKey
    = "com.fritz.sdk.notifications.active-model-changed"
}

extension Notification.Name {

  /// All Fritz errors are posted under this name
  public static let fritzError = Notification.Name(NSNotification.errorNotificationKey)

  /// Posted when a model is updated OTA
  public static let modelUpdated = Notification.Name(NSNotification.modelUpdatedNotificationKey)

  /// Posted when a model is updated OTA
  public static let activeModelChanged = Notification.Name(
    NSNotification.activeModelChangedNotificationKey
  )
}
