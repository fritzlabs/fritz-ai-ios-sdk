//
//  PatternStyleModel.swift
//  FritzVisionStyleModelPatterns
//
//  Created by Christopher Kelly on 11/6/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation

/// Enumeration of all available styles.
@objc(PatternStyleModel)
@available(iOS 12.0, *)
public class PatternStyleModel: NSObject {

  /// Available styles.
  @objc(FritzVisionPatternStyle)
  public enum Style: Int, CaseIterable {
    case blueArrow
    case christmasLights
    case comic
    case filament
    case lampPost
    case mosaic
    case notreDame
    case shades
    case sketch
    case snowflake
    case sprinkles
    case swirl
    case tile
    case vector
    case kaleidoscope
    case pinkBlueRhombus

    public var name: String {
      switch self {
      case .blueArrow:
        return "blueArrow"
      case .christmasLights:
        return "christmasLights"
      case .comic:
        return "comic"
      case .filament:
        return "filament"
      case .lampPost:
        return "lampPost"
      case .mosaic:
        return "mosaic"
      case .notreDame:
        return "notreDame"
      case .shades:
        return "shades"
      case .sketch:
        return "sketch"
      case .snowflake:
        return "snowflake"
      case .sprinkles:
        return "sprinkles"
      case .swirl:
        return "swirl"
      case .tile:
        return "tile"
      case .vector:
        return "vector"
      case .kaleidoscope:
        return "kaleidoscope"
      case .pinkBlueRhombus:
        return "pinkBlueRhombus"

      }
    }

    public static func getFromName(_ name: String) -> Style? {
      switch name {
      case "blueArrow":
        return .blueArrow
      case "christmasLights":
        return .christmasLights
      case "comic":
        return .comic
      case "filament":
        return .filament
      case "lampPost":
        return .lampPost
      case "mosaic":
        return .mosaic
      case "notreDame":
        return .notreDame
      case "shades":
        return .shades
      case "sketch":
        return .sketch
      case "snowflake":
        return .snowflake
      case "sprinkles":
        return .sprinkles
      case "swirl":
        return .swirl
      case "tile":
        return .tile
      case "vector":
        return .vector
      case "kaleidoscope":
        return .kaleidoscope
      case "pinkBlueRhombus":
        return .pinkBlueRhombus

      default:
        return nil
      }
    }

    /// Build FritzVisionStylePredictor from style.
    public func build() -> FritzVisionStylePredictor {
      var model: SwiftIdentifiedModel!

      switch self {
      case .blueArrow:
        model = try! blue_arrow_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .christmasLights:
        model = try! christmas_lights_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .comic:
        model = try! comic_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .filament:
        model = try! filament_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .lampPost:
        model = try! lamp_post_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .mosaic:
        model = try! mosaic_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .notreDame:
        model = try! notre_dame_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .shades:
        model = try! shades_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .sketch:
        model = try! sketch_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .snowflake:
        model = try! snowflake_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .sprinkles:
        model = try! sprinkles_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .swirl:
        model = try! swirl_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .tile:
        model = try! tile_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .vector:
        model = try! vector_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .kaleidoscope:
        model = try! kaleidoscope_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .pinkBlueRhombus:
        model = try! pink_blue_rhombus_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      }

      return FritzVisionStylePredictor(model: model)
    }
  }

  /// Build FritzVisionStylePredictor from style. Useful when using Objective-C.
  @objc(buildForPattern:)
  public static func build(_ style: Style) -> FritzVisionStylePredictor {
    return style.build()
  }

  /// Returns a list of all initialized style predictors.
  @objc(allModels)
  public static func allModels() -> [FritzVisionStylePredictor] {
    Style.allCases.map { $0.build() }
  }
}
