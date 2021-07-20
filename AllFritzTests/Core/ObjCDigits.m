//
// ObjCDigits.m
//
// This file was automatically generated and should not be edited.
//

#import "ObjCDigits.h"

@implementation ObjCDigitsInput

- (instancetype)initWithInput1:(MLMultiArray *)input1 {
    if (self) {
        _input1 = input1;
    }
    return self;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"input1"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"input1"]) {
        return [MLFeatureValue featureValueWithMultiArray:_input1];
    }
    return nil;
}

@end

@implementation ObjCDigitsOutput

- (instancetype)initWithOutput1:(MLMultiArray *)output1 {
    if (self) {
        _output1 = output1;
    }
    return self;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"output1"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"output1"]) {
        return [MLFeatureValue featureValueWithMultiArray:_output1];
    }
    return nil;
}

@end

@implementation ObjCDigits

+ (NSURL *)urlOfModelInThisBundle {
    NSString *assetPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Digits" ofType:@"mlmodelc"];
    return [NSURL fileURLWithPath:assetPath];
}

- (nullable instancetype)init {
        return [self initWithContentsOfURL:self.class.urlOfModelInThisBundle error:nil];
}

- (nullable instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError * _Nullable * _Nullable)error {
    self = [super init];
    if (!self) { return nil; }
    _model = [MLModel modelWithContentsOfURL:url error:error];
    if (_model == nil) { return nil; }
    return self;
}

- (nullable instancetype)initWithConfiguration:(MLModelConfiguration *)configuration error:(NSError * _Nullable * _Nullable)error {
        return [self initWithContentsOfURL:self.class.urlOfModelInThisBundle configuration:configuration error:error];
}

- (nullable instancetype)initWithContentsOfURL:(NSURL *)url configuration:(MLModelConfiguration *)configuration error:(NSError * _Nullable * _Nullable)error {
    self = [super init];
    if (!self) { return nil; }
    _model = [MLModel modelWithContentsOfURL:url configuration:configuration error:error];
    if (_model == nil) { return nil; }
    return self;
}

- (nullable ObjCDigitsOutput *)predictionFromFeatures:(ObjCDigitsInput *)input error:(NSError * _Nullable * _Nullable)error {
    return [self predictionFromFeatures:input options:[[MLPredictionOptions alloc] init] error:error];
}

- (nullable ObjCDigitsOutput *)predictionFromFeatures:(ObjCDigitsInput *)input options:(MLPredictionOptions *)options error:(NSError * _Nullable * _Nullable)error {
    id<MLFeatureProvider> outFeatures = [_model predictionFromFeatures:input options:options error:error];
    return [[ObjCDigitsOutput alloc] initWithOutput1:[outFeatures featureValueForName:@"output1"].multiArrayValue];
}

- (nullable ObjCDigitsOutput *)predictionFromInput1:(MLMultiArray *)input1 error:(NSError * _Nullable * _Nullable)error {
    ObjCDigitsInput *input_ = [[ObjCDigitsInput alloc] initWithInput1:input1];
    return [self predictionFromFeatures:input_ error:error];
}

- (nullable NSArray<ObjCDigitsOutput *> *)predictionsFromInputs:(NSArray<ObjCDigitsInput*> *)inputArray options:(MLPredictionOptions *)options error:(NSError * _Nullable * _Nullable)error {
    id<MLBatchProvider> inBatch = [[MLArrayBatchProvider alloc] initWithFeatureProviderArray:inputArray];
    id<MLBatchProvider> outBatch = [_model predictionsFromBatch:inBatch options:options error:error];
    NSMutableArray<ObjCDigitsOutput*> *results = [NSMutableArray arrayWithCapacity:(NSUInteger)outBatch.count];
    for (NSInteger i = 0; i < outBatch.count; i++) {
        id<MLFeatureProvider> resultProvider = [outBatch featuresAtIndex:i];
        ObjCDigitsOutput * result = [[ObjCDigitsOutput alloc] initWithOutput1:[resultProvider featureValueForName:@"output1"].multiArrayValue];
        [results addObject:result];
    }
    return results;
}

@end
