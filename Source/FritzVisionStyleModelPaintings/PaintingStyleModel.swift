//
//  FritzVisionStyleModelRetriever.swift
//  FritzVisionStyleModelPaintings
//
//  Created by Steven Yeung on 10/21/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import FritzVision

@objc(PaintingStyleModel)
@available(iOS 12.0, *)
public class PaintingStyleModel: NSObject {

  /// Available styles.
  @objc(FritzVisionPaintingStyle)
  public enum Style: Int, CaseIterable {
    case bicentennialPrint
    case femmes
    case headOfClown
    case horsesOnSeashore
    case poppyField
    case ritmoPlastico
    case starryNight
    case theScream
    case theTrial

    public var name: String {
      switch self {
      case .bicentennialPrint:
        return "bicentennialPrint"
      case .femmes:
        return "femmes"
      case .headOfClown:
        return "headOfClown"
      case .horsesOnSeashore:
        return "horsesOnSeashore"
      case .poppyField:
        return "poppyField"
      case .ritmoPlastico:
        return "ritmoPlastico"
      case .starryNight:
        return "starryNight"
      case .theScream:
        return "theScream"
      case .theTrial:
        return "theTrial"
      }
    }

    public static func getFromName(_ name: String) -> Style? {
      switch name {
      case "bicentennialPrint":
        return .bicentennialPrint
      case "femmes":
        return .femmes
      case "headOfClown":
        return .headOfClown
      case "horsesOnSeashore":
        return .horsesOnSeashore
      case "poppyField":
        return .poppyField
      case "ritmoPlastico":
        return .ritmoPlastico
      case "starryNight":
        return .starryNight
      case "theScream":
        return .theScream
      case "theTrial":
        return .theTrial
      default:
        return nil
      }
    }

    /// Build FritzVisionStylePredictor from style.
    public func build() -> FritzVisionStylePredictor {
      var model: SwiftIdentifiedModel!

      switch self {
      case .bicentennialPrint:
        model = try! bicentennial_print_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .femmes:
        model = try! femmes_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .headOfClown:
        model = try! head_of_clown_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .horsesOnSeashore:
        model = try! horses_on_seashore_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .poppyField:
        model = try! poppy_field_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .ritmoPlastico:
        model = try! ritmo_plastico_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .starryNight:
        model = try! starry_night_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .theScream:
        model = try! the_scream_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      case .theTrial:
        model = try! the_trial_512x512_a025_stable_flexible(configuration: MLModelConfiguration())
      }

      return FritzVisionStylePredictor(model: model)
    }
  }

  /// Build FritzVisionStylePredictor from style. Useful when using Objective-C.
  @objc(buildForPainting:)
  static func build(_ style: Style) -> FritzVisionStylePredictor {
    return style.build()
  }

  /// Returns a list of all initialized style predictors.
  @objc(allModels)
  public static func allModels() -> [FritzVisionStylePredictor] {
    Style.allCases.map { $0.build() }
  }
}
