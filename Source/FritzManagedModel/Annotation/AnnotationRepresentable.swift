//
//  AnnotationRepresentable.swift
//  FritzManagedModel
//
//  Created by Christopher Kelly on 11/14/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation


/// A data type that can be represented as annotations that describe a specific type.
@available(iOS 11.0, *)
public protocol AnnotationRepresentable {
  /// Type that the `AnnotationType` is for.
  // associatedtype : Annotatable
  associatedtype Source
  associatedtype Annotation: AnnotationType

  func annotations(for input: Source) -> [Annotation]
}


@available(iOS 11.0, *)
extension Array: AnnotationRepresentable where Element: AnnotationRepresentable {

  public func annotations(for input: Element.Source) -> [Element.Annotation] {
    return self.flatMap { $0.annotations(for: input) }
  }
}
