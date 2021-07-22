//
//  PointFilterable.swift
//  FritzVision
//
//  Created by Christopher Kelly on 4/5/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

public protocol FilterOptions {

  init()

}

/// The methods adopted by the object used to smoothe a 2D or 3D point.
public protocol PointFilterable {
  associatedtype T: PointType
  associatedtype SmoothingOptionsType: FilterOptions

  init(options: SmoothingOptionsType)

  func filter(_ point: T) -> T
}
