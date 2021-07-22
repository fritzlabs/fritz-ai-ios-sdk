//
//  CocoImageAnnotation.swift
//  FritzManagedModel
//
//  Created by Christopher Kelly on 11/19/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// COCO Annotation
public struct CocoImageAnnotation: Codable, AnnotationType {

  /// Bounding box
  public struct BoundingBox: Codable {
    let xmin: CGFloat
    let ymin: CGFloat
    let width: CGFloat
    let height: CGFloat

    public init(xmin: CGFloat, ymin: CGFloat, width: CGFloat, height: CGFloat) {
      self.xmin = xmin
      self.ymin = ymin
      self.width = width
      self.height = height
    }
    
    public init(rect: CGRect) {
      self.xmin = rect.minX
      self.ymin = rect.minY
      self.width = rect.width
      self.height = rect.height
    }
  }
  
  /// Segmentation
  public struct Segmentation: Codable {
    let mask: [[Int8]]
    
    public init(mask: [[Int8]]) {
      self.mask = mask
    }
  }

  /// Keypoint
  public struct Keypoint: Codable {
    public enum KeypointVisibility: Int, Codable {
      case notLabeled
      case labeledButNotVisible
      case labeledAndVisible
    }

    let id: Int
    let label: String
    let x: CGFloat
    let y: CGFloat
    let visibility: Int

    public init(id: Int, label: String, x: CGFloat, y: CGFloat, visibility: KeypointVisibility) {
      self.id = id
      self.label = label
      self.x = x
      self.y = y
      self.visibility = visibility.rawValue
    }
  }
  
  // Segmentation
  public let segmentation: Segmentation?

  /// Bounding box
  public let bbox: BoundingBox?

  /// Keypoints
  public let keypoints: [Keypoint]?

  public let label: String

  /// If true label is an image label.
  public let isImageLabel: Bool
  
  /// Format of annotation
  public var format: String { AnnotationFormat.coco.rawValue }
  
  public init(bbox: BoundingBox?, keypoints: [Keypoint]?, segmentation: Segmentation?, label: String, isImageLabel: Bool = false) {
    self.bbox = bbox
    self.keypoints = keypoints
    self.label = label
    self.isImageLabel = isImageLabel
    self.segmentation = segmentation
  }

  // this is pretty hacky, I'd prefer to just call encode on the object, but easiest way to pass
  // annotations to api.
  public var requestOptions: RequestOptions {
    var boundingBox: [String: CGFloat]? = nil
    if let bbox = bbox {
      boundingBox = ["xmin": bbox.xmin, "ymin": bbox.ymin, "width": bbox.width, "height": bbox.height]
    }
    
    var segmentationArray: [String: [[Int8]]]? = nil
    if let segmentation = segmentation {
      segmentationArray = ["mask": segmentation.mask]
    }
    
    return [
      "keypoints": keypoints?.map {
        ["id": $0.id, "label": $0.label, "x": $0.x, "y": $0.y, "visibility": $0.visibility]
      } as Any,
      "bbox": boundingBox as Any,
      "segmentation": segmentationArray as Any,
      "label": label,
      "is_image_label": isImageLabel
    ]
  }
}
