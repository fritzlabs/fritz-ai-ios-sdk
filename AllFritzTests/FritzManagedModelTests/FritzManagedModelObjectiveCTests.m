//
//  FritzManagedModelObjectiveCTests.m
//  AllFritzTests
//
//  Created by Christopher Kelly on 11/21/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FritzObjCTestCase.h"


@implementation ObjCDigits(Fritz)
+ (NSString * _Nonnull)fritzModelIdentifier {
    return @"digits";
}

+ (NSInteger)fritzPackagedModelVersion {
    return 1;
}

+ (FritzConfiguration *)fritzConfiguration {
    return [FritzCore configuration];
}
@end


@interface FritzManagedModelObjectiveCTests: FritzObjCTestCase
@end


@implementation FritzManagedModelObjectiveCTests

- (void)testCallingFritzProperlyWrapsModel {
    FritzManagedModel *managedModel __attribute__((unused)) = [[FritzManagedModel alloc] initWithIdentifiedModel:model];
    ObjCDigits* fritzModel = [model fritz];
    NSError *anyError;
    MLMultiArray* input = [[MLMultiArray alloc] initWithShape:[NSArray arrayWithObjects:[NSNumber numberWithInt: 1], [NSNumber numberWithInt: 28], [NSNumber numberWithInt: 28], nil] dataType:MLMultiArrayDataTypeDouble error:&anyError];

    ObjCDigitsOutput* results __attribute__((unused)) = [fritzModel predictionFromInput1:input error:&anyError];
    SessionManager* sessionManager = [[FritzCore configuration] sessionManager];
    NSArray* trackedItems = [sessionManager trackRequestQueueItemTypes];
    NSArray* expectedItems = [NSArray arrayWithObjects:@"prediction", nil];
    XCTAssertEqualObjects(trackedItems, expectedItems);
}

- (void)testInitializeWithIdentifiedModel {
    FritzManagedModel *managedModel = [[FritzManagedModel alloc] initWithIdentifiedModel:model];
    FritzModelConfiguration *expectedConfig = [[FritzModelConfiguration alloc] initWithIdentifier:[ObjCDigits fritzModelIdentifier] version:[ObjCDigits fritzPackagedModelVersion] cpuAndGPUOnly:false];
    XCTAssertEqualObjects([managedModel activeModelConfig], expectedConfig);
}

- (void)testInitializeWithModelConfiguration {
    FritzModelConfiguration* config = [[FritzModelConfiguration alloc] initFromIdentifiedModel:model];

    FritzManagedModel* managedModel = [[FritzManagedModel alloc] initWithModelConfig:config sessionManager:[[ObjCDigits fritzConfiguration] sessionManager] loadActive:true packagedModelType:nil];
    XCTAssertEqualObjects([managedModel activeModelConfig], config);
}

- (void)testLoadModel {

    FritzManagedModel* managedModel = [[FritzManagedModel alloc] initWithIdentifiedModel:model];
    FritzMLModel* fritzModel = [managedModel loadModelWithIdentifiedModel:model];
    XCTAssertEqualObjects([managedModel activeModelConfig], [fritzModel activeModelConfig]);
 }

- (void)testFetchModel {
    FritzManagedModel* managedModel = [[FritzManagedModel alloc] initWithIdentifiedModel:model];
    XCTestExpectation *fritzFetchPrediction = [self expectationWithDescription:@"Fritz Prediction Finished"];

    [managedModel fetchModelWithCompletionHandler:^(FritzMLModel * _Nullable result, NSError * _Nullable error) {
        XCTAssertNil(error);
        // No model should be loaded?
        XCTAssertNotNil(result);
        [fritzFetchPrediction fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end;
