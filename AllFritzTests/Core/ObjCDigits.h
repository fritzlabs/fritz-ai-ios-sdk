//
// ObjCDigits.h
//
// This file was automatically generated and should not be edited.
//

#import <Foundation/Foundation.h>
#import <CoreML/CoreML.h>
#include <stdint.h>

NS_ASSUME_NONNULL_BEGIN


/// Model Prediction Input Type
API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0)) __attribute__((visibility("hidden")))
@interface ObjCDigitsInput : NSObject<MLFeatureProvider>

/// input1 as 1 x 28 x 28 3-dimensional array of doubles
@property (readwrite, nonatomic, strong) MLMultiArray * input1;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithInput1:(MLMultiArray *)input1;
@end


/// Model Prediction Output Type
API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0)) __attribute__((visibility("hidden")))
@interface ObjCDigitsOutput : NSObject<MLFeatureProvider>

/// output1 as 10 element vector of doubles
@property (readwrite, nonatomic, strong) MLMultiArray * output1;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithOutput1:(MLMultiArray *)output1;
@end


/// Class for model loading and prediction
API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0)) __attribute__((visibility("hidden")))
@interface ObjCDigits : NSObject
@property (readonly, nonatomic, nullable) MLModel * model;
- (nullable instancetype)init;
- (nullable instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError * _Nullable * _Nullable)error;
- (nullable instancetype)initWithConfiguration:(MLModelConfiguration *)configuration error:(NSError * _Nullable * _Nullable)error API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)) __attribute__((visibility("hidden")));
- (nullable instancetype)initWithContentsOfURL:(NSURL *)url configuration:(MLModelConfiguration *)configuration error:(NSError * _Nullable * _Nullable)error API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)) __attribute__((visibility("hidden")));

/**
    Make a prediction using the standard interface
    @param input an instance of ObjCDigitsInput to predict from
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as ObjCDigitsOutput
*/
- (nullable ObjCDigitsOutput *)predictionFromFeatures:(ObjCDigitsInput *)input error:(NSError * _Nullable * _Nullable)error;

/**
    Make a prediction using the standard interface
    @param input an instance of ObjCDigitsInput to predict from
    @param options prediction options
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as ObjCDigitsOutput
*/
- (nullable ObjCDigitsOutput *)predictionFromFeatures:(ObjCDigitsInput *)input options:(MLPredictionOptions *)options error:(NSError * _Nullable * _Nullable)error;

/**
    Make a prediction using the convenience interface
    @param input1 as 1 x 28 x 28 3-dimensional array of doubles:
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as ObjCDigitsOutput
*/
- (nullable ObjCDigitsOutput *)predictionFromInput1:(MLMultiArray *)input1 error:(NSError * _Nullable * _Nullable)error;

/**
    Batch prediction
    @param inputArray array of ObjCDigitsInput instances to obtain predictions from
    @param options prediction options
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the predictions as NSArray<ObjCDigitsOutput *>
*/
- (nullable NSArray<ObjCDigitsOutput *> *)predictionsFromInputs:(NSArray<ObjCDigitsInput*> *)inputArray options:(MLPredictionOptions *)options error:(NSError * _Nullable * _Nullable)error API_AVAILABLE(macos(10.14), ios(12.0), watchos(5.0), tvos(12.0)) __attribute__((visibility("hidden")));
@end

NS_ASSUME_NONNULL_END
