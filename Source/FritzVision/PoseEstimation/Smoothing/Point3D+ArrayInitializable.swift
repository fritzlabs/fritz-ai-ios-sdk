//
//  Point+ArrayInitializable.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/9/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public protocol ArrayInitializable: PointType {
  init(with array: [CGFloat])
}

extension Point3D: ArrayInitializable {
  public convenience init(with array: [CGFloat]) {
    self.init(x: array[0], y: array[1], z: array[2])
  }
}
