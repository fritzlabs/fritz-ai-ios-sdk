//
//  SessionEvent.swift
//  Fritz
//
//  Created by Andrew Barba on 11/3/17.
//  Copyright © 2017 Fritz Labs Incorporated. All rights reserved.
//

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public struct SessionEvent {

  public enum EventType: String {
    case applicationDidEnterBackground = "app_did_enter_background"
    case applicationWillEnterForeground = "app_will_enter_foreground"
    case applicationDidBecomeActive = "app_did_become_active"
    case applicationWillResignActive = "app_will_resign_active"
    case modelInstalled = "model_installed"
    case modelDownloadCompleted = "model_download_completed"
    case modelDownloadFailed = "model_download_failed"
    case modelCompileCompleted = "model_compile_completed"
    case modelCompileFailed = "model_compile_failed"
    case modelDecryptionCompleted = "model_decryption_completed"
    case modelDecryptionFailed = "model_decryption_failed"
    case prediction = "prediction"
    case inputOutputSample = "input_output_sample"
    case predictionAnnotation = "prediction_annotation"
  }

  public let type: EventType

  public let data: RequestOptions

  public let sessionIdentifier = FritzCore.sessionIdentifier

  public let timestamp = Date().timeIntervalSince1970

  public init(type: EventType, data: RequestOptions) {
    self.type = type
    self.data = data
  }
}
