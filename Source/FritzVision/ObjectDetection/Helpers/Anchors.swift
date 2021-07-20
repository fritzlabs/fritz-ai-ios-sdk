//
//  Anchors.swift
//  FritzVisionObjectModel
//
//  Created by Christopher Kelly on 7/5/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

/// Anchor box used in object detection models.
public struct Anchor {

  public let yCenter: Double
  public let xCenter: Double
  public let height: Double
  public let width: Double

  public init(yCenter: Double, xCenter: Double, height: Double, width: Double) {
    self.yCenter = yCenter
    self.xCenter = xCenter
    self.height = height
    self.width = width
  }

  public var xMin: Double {
    return xCenter - (width / 2.0)
  }

  public var xMax: Double {
    return xCenter + (width / 2.0)
  }

  public var yMin: Double {
    return yCenter - (height / 2.0)
  }

  public var yMax: Double {
    return yCenter + (height / 2.0)
  }
}

let LABELS: [Int: String] = [
  1: "person",
  2: "bicycle",
  3: "car",
  4: "motorcycle",
  5: "airplane",
  6: "bus",
  7: "train",
  8: "truck",
  9: "boat",
  10: "traffic light",
  11: "fire hydrant",
  13: "stop sign",
  14: "parking meter",
  15: "bench",
  16: "bird",
  17: "cat",
  18: "dog",
  19: "horse",
  20: "sheep",
  21: "cow",
  22: "elephant",
  23: "bear",
  24: "zebra",
  25: "giraffe",
  27: "backpack",
  28: "umbrella",
  31: "handbag",
  32: "tie",
  33: "suitcase",
  34: "frisbee",
  35: "skis",
  36: "snowboard",
  37: "sports ball",
  38: "kite",
  39: "baseball bat",
  40: "baseball glove",
  41: "skateboard",
  42: "surfboard",
  43: "tennis racket",
  44: "bottle",
  46: "wine glass",
  47: "cup",
  48: "fork",
  49: "knife",
  50: "spoon",
  51: "bowl",
  52: "banana",
  53: "apple",
  54: "sandwich",
  55: "orange",
  56: "broccoli",
  57: "carrot",
  58: "hot dog",
  59: "pizza",
  60: "donut",
  61: "cake",
  62: "chair",
  63: "couch",
  64: "potted plant",
  65: "bed",
  67: "dining table",
  70: "toilet",
  72: "tv",
  73: "laptop",
  74: "mouse",
  75: "remote",
  76: "keyboard",
  77: "cell phone",
  78: "microwave",
  79: "oven",
  80: "toaster",
  81: "sink",
  82: "refrigerator",
  84: "book",
  85: "clock",
  86: "vase",
  87: "scissors",
  88: "teddy bear",
  89: "hair drier",
  90: "toothbrush",
]

@available(iOS 11.0, *)
enum Anchors {
  static let numAnchors = 1917

  static let ssdAnchors: [Anchor] = {
    // [yCenter, xCenter, height, width]
    let bundle = Bundle(for: FritzVisionImage.self)

    guard let path = bundle.path(forResource: "Anchors", ofType: "csv"),
      let text = try? String(contentsOfFile: path, encoding: .utf8)
    else {
      fatalError("Unable to load Anchors")
    }
    let arr: [[Double]] = text.split(separator: "\n").map {
      $0.split(separator: ",").compactMap { Double($0) }
    }
    guard numAnchors == arr.count else {
      fatalError("Incorrect number of anchors")
    }

    return arr.map { row in
      return Anchor(yCenter: row[0], xCenter: row[1], height: row[2], width: row[3])
    }
  }()
}
