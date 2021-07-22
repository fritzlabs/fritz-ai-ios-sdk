//
// Digits.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML

/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class DigitsDownload {
  var model: MLModel

  /// URL of model assuming it was installed in the same bundle as this class
  class var urlOfModelInThisBundle: URL {
    let bundle = Bundle(for: Digits.self)
    return bundle.url(forResource: "Digits", withExtension: "mlmodelc")!
  }

  /**
   Construct a model with explicit path to mlmodelc file
   - parameters:
   - url: the file url of the model
   - throws: an NSError object that describes the problem
   */
  init(contentsOf url: URL) throws {
    self.model = try MLModel(contentsOf: url)
  }

  /// Construct a model that automatically loads the model from the app's bundle
  convenience init() {
    try! self.init(contentsOf: type(of: self).urlOfModelInThisBundle)
  }

  /**
   Construct a model with configuration
   - parameters:
   - configuration: the desired model configuration
   - throws: an NSError object that describes the problem
   */
  @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
  convenience init(configuration: MLModelConfiguration) throws {
    try self.init(contentsOf: type(of: self).urlOfModelInThisBundle, configuration: configuration)
  }

  /**
   Construct a model with explicit path to mlmodelc file and configuration
   - parameters:
   - url: the file url of the model
   - configuration: the desired model configuration
   - throws: an NSError object that describes the problem
   */
  @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
  init(contentsOf url: URL, configuration: MLModelConfiguration) throws {
    self.model = try MLModel(contentsOf: url, configuration: configuration)
  }

  /**
   Make a prediction using the structured interface
   - parameters:
   - input: the input to the prediction as DigitsInput
   - throws: an NSError object that describes the problem
   - returns: the result of the prediction as DigitsOutput
   */
  func prediction(input: DigitsInput) throws -> DigitsOutput {
    return try self.prediction(input: input, options: MLPredictionOptions())
  }

  /**
   Make a prediction using the structured interface
   - parameters:
   - input: the input to the prediction as DigitsInput
   - options: prediction options
   - throws: an NSError object that describes the problem
   - returns: the result of the prediction as DigitsOutput
   */
  func prediction(input: DigitsInput, options: MLPredictionOptions) throws -> DigitsOutput {
    let outFeatures = try model.prediction(from: input, options: options)
    return DigitsOutput(features: outFeatures)
  }

  /**
   Make a prediction using the convenience interface
   - parameters:
   - input1 as 1 x 28 x 28 3-dimensional array of doubles
   - throws: an NSError object that describes the problem
   - returns: the result of the prediction as DigitsOutput
   */
  func prediction(input1: MLMultiArray) throws -> DigitsOutput {
    let input_ = DigitsInput(input1: input1)
    return try self.prediction(input: input_)
  }

  /**
   Make a batch prediction using the structured interface
   - parameters:
   - inputs: the inputs to the prediction as [DigitsInput]
   - options: prediction options
   - throws: an NSError object that describes the problem
   - returns: the result of the prediction as [DigitsOutput]
   */
  @available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
  func predictions(inputs: [DigitsInput], options: MLPredictionOptions = MLPredictionOptions())
    throws -> [DigitsOutput]
  {
    let batchIn = MLArrayBatchProvider(array: inputs)
    let batchOut = try model.predictions(from: batchIn, options: options)
    var results: [DigitsOutput] = []
    results.reserveCapacity(inputs.count)
    for i in 0..<batchOut.count {
      let outProvider = batchOut.features(at: i)
      let result = DigitsOutput(features: outProvider)
      results.append(result)
    }
    return results
  }
}
