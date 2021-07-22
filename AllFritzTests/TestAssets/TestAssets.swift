//
//  TestAssets.swift
//  TestAssets
//
//  Created by Christopher Kelly on 11/1/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import FritzVision
import UIKit

public enum ImageVariant: Int {
  case normal = 1
  case wide = 2
  case tall = 3
}

@objc(TestImage)
public enum TestImage: Int {
  case jumpingJacks
  case tennis
  case person
  case cat
  case indoor
  case tvRight
  case indoorWide
  case indoorTall
  case hair
  case coke
  case me
  case blonde
  case dentastix
  case dentastix2
  case dentastix2Rotated
  case family
  case skiing
  case rocketbook

  /// Filename of string.  Created to allow for obj-c compatibility
  var fileName: String {
    switch self {
    case .jumpingJacks: return "jumping-jacks.jpg"
    case .tennis: return "tennis.jpg"
    case .person: return "person.jpg"
    case .cat: return "cat.jpg"
    case .indoor: return "testImage.png"
    case .tvRight: return "tvRight.jpg"
    case .indoorWide: return "testImageWide.png"
    case .indoorTall: return "testImageTall.png"
    case .hair: return "hair.jpg"
    case .coke: return "coke.jpg"
    case .me: return "me.jpg"
    case .blonde: return "blonde.png"
    case .dentastix: return "dentastix.jpg"
    case .dentastix2: return "dentastix2.png"
    case .dentastix2Rotated: return "dentastix2_rotated.png"
    case .family: return "family.png"
    case .skiing: return "skiing.jpg"
    case .rocketbook: return "rocketbook.png"
    }
  }
  private func image(for resource: String) -> UIImage {
    let bundle = Bundle(for: TestAssets.self)
    let path = bundle.path(forResource: resource, ofType: nil)!
    return UIImage(contentsOfFile: path)!
  }

  /// UIImage for TestImage.
  var image: UIImage {
    return image(for: fileName)
  }

  /// FritzVisionImage for TestImage
  var fritzImage: FritzVisionImage {
    return FritzVisionImage(image: image)
  }

  public func fritzImage(
    orientation: CGImagePropertyOrientation
  ) -> FritzVisionImage {
    return FritzVisionImage(image: image, orientation: orientation)
  }
}

public enum TestFiles: String {
  case stevenFace = "StevenFace.mov"
}

@objc(TestAssets)
public class TestAssets: NSObject {

  @objc(init)
  override public init() {}

  /// Helper function for objective-c code that cannot access the variable on the image.
  @objc(fritzImageForTestImage:)
  @available(swift, obsoleted: 1.0)
  public func fritzImage(_ testImage: TestImage) -> FritzVisionImage {
    return testImage.fritzImage
  }

  /// Helper function for objective-c code that cannot access the variable on the image.
  @objc(imageForTestImage:)
  @available(swift, obsoleted: 1.0)
  public func image(_ testImage: TestImage) -> UIImage {
    return testImage.image
  }

  public func video(for resource: String) -> URL {
    let bundle = Bundle(for: type(of: self))
    let path = "file://\(bundle.path(forResource: resource, ofType: nil)!)"
    return URL(string: path)!
  }

  var modelResumeDataPath: String {
    // Sorry about this
    let bundle = Bundle(for: type(of: self))
    return bundle.path(forResource: "DigitResumeData.txt", ofType: nil)!
  }

  public func getFaceVideo() -> URL {
    return video(for: TestFiles.stevenFace.rawValue)
  }
}


extension FaceMasks: SwiftIdentifiedModel {

  static let modelIdentifier = "FaceMasks"
  static let packagedModelVersion = 1

}
