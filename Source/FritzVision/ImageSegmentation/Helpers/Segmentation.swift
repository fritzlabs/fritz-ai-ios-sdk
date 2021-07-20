//
//  MaskArray.swift
//  Fritz
//
//  Created by Jameson Toole on 5/15/20.
//  Copyright © 2020 Fritz Labs Incorporated. All rights reserved.
//

import Foundation


public struct Segmentation {
  public let mask: [[Float]]
  public let label: String
  
  public init(mask: [[Float]], label: String) {
    self.mask = mask
    self.label = label
  }
  
  public var intMask: [[Int8]] {
    return mask.map { row in row.map { Int8($0) }}
  }
}



public enum ArrayError: Error {
  case invalidSize

  public func message() -> String {
    return "Array cannot be reshaped to 2D array."
  }
}


extension Array where Element == Float {
  public func as2D(width: Int, height: Int) throws -> [[Float]] {
    guard width * height == self.count else {
      throw ArrayError.invalidSize
    }
    var array: [[Float]] = []
    for jdx in 0..<height {
      var row = Array(repeating: 0.0, count: width)
      for idx in 0..<width {
        row[idx] = self[width * jdx + idx]
      }
      array.append(row)
    }
    return array
  }
}
