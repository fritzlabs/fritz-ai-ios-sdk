//
//  DigitsModels.swift
//  AllFritzTests
//
//  Created by Christopher Kelly on 11/14/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

import Foundation
import FritzManagedModel


extension Digits: SwiftIdentifiedModel {

  static let modelIdentifier = "digits"

  static let packagedModelVersion = 1

}

class DigitsDifferentVersion: SwiftIdentifiedModel {
  static let modelIdentifier = "digits"

  // Active model is 1 on response from server
  static let packagedModelVersion = 2

  var model: MLModel

  init(model: MLModel) {
    self.model = model
  }

  static var urlOfModelInThisBundle: URL = Digits.urlOfModelInThisBundle

  convenience init() {
    self.init(model: try! Digits(configuration: MLModelConfiguration()).model)
  }
}

class DigitsPinnedVersion: SwiftIdentifiedModel {
  static let modelIdentifier = "digits-pinned"

  // Active model is 1 on response from server
  static let packagedModelVersion = 2

  static let pinnedModelVersion = 3

  var model: MLModel

  init(model: MLModel) {
    self.model = model
  }

  static var urlOfModelInThisBundle: URL = Digits.urlOfModelInThisBundle

  convenience init() {
    self.init(model: try! Digits(configuration: MLModelConfiguration()).model)
  }
}

class DigitsFake: SwiftIdentifiedModel {

  static let modelIdentifier = "digits-fake"

  static let packagedModelVersion = 1

  static var urlOfModelInThisBundle: URL = URL(fileURLWithPath: "badpath")

  var model: MLModel

  init(model: MLModel) {
    self.model = model
  }
}
