//
//  DataAnnotationType.swift
//  FritzVision
//
//  Created by Christopher Kelly on 11/13/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// A type that represents annotations for an object.
public protocol AnnotationType: Codable {

  var format: String { get }

  /// Annotation formatted as `RequestOptions` for passing to server.
  var requestOptions: RequestOptions { get }

}

// Format of annotation structure.
public enum AnnotationFormat: String, RawRepresentable, Codable {
  case coco = "coco"
}

