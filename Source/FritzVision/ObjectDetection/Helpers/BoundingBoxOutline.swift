//
//  BoundingBoxOutline.swift
//  FritzVisionObjectModel
//
//  Created by Christopher Kelly on 7/5/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import UIKit

@objc(BoundingBoxOutline)
public class BoundingBoxOutline: NSObject {
  let shapeLayer: CAShapeLayer
  let textLayer: CATextLayer

  public init(fontSize: CGFloat = 14.0) {
    shapeLayer = CAShapeLayer()
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.lineWidth = 4
    shapeLayer.isHidden = true

    textLayer = CATextLayer()
    textLayer.isHidden = true
    textLayer.contentsScale = UIScreen.main.scale
    textLayer.fontSize = fontSize
    textLayer.font = UIFont.systemFont(ofSize: textLayer.fontSize)
    textLayer.alignmentMode = .center
  }

  /// Add shape and text to parent layer
  ///
  /// - Parameter parent: parent CALayer
  @objc(parent:)
  public func addToLayer(_ parent: CALayer) {
    parent.addSublayer(shapeLayer)
    parent.addSublayer(textLayer)
  }

  /// Show Bounding box.
  ///
  /// - Parameters:
  ///   - frame: CGRect of coordinates to draw box
  ///   - label: Classified label
  ///   - color: Color of bounding box outline
  ///   - textColor: Classified label text
  @objc(frame:label:color:textColor:)
  public func show(frame: CGRect, label: String, color: UIColor, textColor: UIColor = .black) {
    CATransaction.setDisableActions(true)

    let path = UIBezierPath(rect: frame)
    shapeLayer.path = path.cgPath
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.isHidden = false

    textLayer.string = label
    textLayer.foregroundColor = textColor.cgColor
    textLayer.backgroundColor = color.cgColor
    textLayer.isHidden = false

    let textRect = label.boundingRect(
      with: CGSize(width: 400, height: 100),
      options: .truncatesLastVisibleLine,
      attributes: [.font: textLayer.font as Any],
      context: nil
    )
    let textSize = CGSize(width: textRect.width + 12, height: textRect.height)
    let textOrigin = CGPoint(x: frame.origin.x - 2, y: frame.origin.y - textSize.height)
    textLayer.frame = CGRect(origin: textOrigin, size: textSize)
  }

  /// Hide bounding box from appearing in view.
  @objc
  public func hide() {
    shapeLayer.isHidden = true
    textLayer.isHidden = true
  }
}
