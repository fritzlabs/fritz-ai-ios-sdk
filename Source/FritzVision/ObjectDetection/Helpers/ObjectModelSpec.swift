//
//  ObjectModelSpec.swift
//  FritzVision
//
//  Created by Steven Yeung on 10/11/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public class ObjectModelSpec {
  static let imageInputKey = "image"

  public struct AnchorBoxModelDef {
    let predictionOutputKey: String
    let offsetOutputKey: String
  }

  public struct BoundingBoxModelDef {
    let confidenceInputKey: String
    let iouInputKey: String
    let classInputKey: String
    let confidenceOutputKey: String
    let coordinateOutputKey: String
  }

  static let anchorBoxModel = AnchorBoxModelDef(
    predictionOutputKey: "class_predictions",
    offsetOutputKey: "bbox_offsets"
  )

  static let boundingBoxModel = BoundingBoxModelDef(
    confidenceInputKey: "confidenceThreshold",
    iouInputKey: "iouThreshold",
    classInputKey: "classes",
    confidenceOutputKey: "confidence",
    coordinateOutputKey: "coordinates"
  )
}
