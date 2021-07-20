//
//  FritzVisionSegmentationPredictorObjectiveCTests.m
//  AllFritzTests
//
//  Created by Christopher Kelly on 11/21/18.
//  Copyright © 2018 Fritz Labs Incorporated. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <XCTest/XCTest.h>
#import <FritzCore/FritzCore.h>
#import <FritzVision/FritzVision.h>

#import <FritzVisionPeopleSegmentationModelFast/FritzVisionPeopleSegmentationModelFast.h>
#import <FritzVisionPeopleSegmentationModelAccurate/FritzVisionPeopleSegmentationModelAccurate.h>
#import <FritzVisionSkySegmentationModelSmall/FritzVisionSkySegmentationModelSmall.h>
#import <FritzVisionOutdoorSegmentationModelSmall/FritzVisionOutdoorSegmentationModelSmall.h>
#import <FritzVisionPetSegmentationModelSmall/FritzVisionPetSegmentationModelSmall.h>
#import "AllFritzTests-Swift.h"

@interface FritzVisionSegmentationPredictorObjectiveCTests: XCTestCase
@end


@implementation FritzVisionSegmentationPredictorObjectiveCTests

- (void)setUp {
    [super setUp];

    FritzSession *session = [[FritzSession alloc] initWithAppToken:@"fritz-test-app-token" apiUrl:@"http://localhost:port" namespace:@"Test"];
    [FritzCore configureWith:[[FritzConfiguration alloc] initWithSession:session]];
}

- (void)testRunPeopleSegmentationModel {
    TestAssets *testAssets = [[TestAssets alloc] init];
    FritzVisionImage *visionImage = [testAssets fritzImageForTestImage:TestImageMe];
    FritzVisionPeopleSegmentationModelAccurate *model = [FritzVisionPeopleSegmentationModelAccurateObjc model];
    FritzVisionSegmentationModelOptions *options = [[FritzVisionSegmentationModelOptions alloc] init];

    XCTestExpectation *fritzPredictExpectation = [self expectationWithDescription:@"Fritz Prediction Finished"];
    [model predict:visionImage options:options completion:^(FritzVisionSegmentationResult * _Nullable result, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(result);
        UIImage* image = [result buildSingleClassMask:FritzVisionPeopleClass.person clippingScoresAbove:.1 zeroingScoresBelow:.1 maxAlpha:255 resize:true color:nil blurRadius:0];
        XCTAssertNotNil(image);
        [fritzPredictExpectation fulfill];
    }];


    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


- (void)testRunSkySegmentationModel {
    TestAssets *testAssets = [[TestAssets alloc] init];
    FritzVisionImage *visionImage = [testAssets fritzImageForTestImage:TestImageSkiing];
    FritzVisionSkySegmentationModelSmall *model = [FritzVisionSkySegmentationModelSmallObjc model];
    FritzVisionSegmentationModelOptions *options = [[FritzVisionSegmentationModelOptions alloc] init];

    XCTestExpectation *fritzPredictExpectation = [self expectationWithDescription:@"Fritz Prediction Finished"];
    [model predict:visionImage options:options completion:^(FritzVisionSegmentationResult * _Nullable result, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(result);
        UIImage* image = [result buildSingleClassMask:FritzVisionSkyClass.sky clippingScoresAbove:.5 zeroingScoresBelow:.5 maxAlpha:255 resize:true color:nil blurRadius:0];
        XCTAssertNotNil(image);
        [fritzPredictExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testRunPetSegmentationModel {
    TestAssets *testAssets = [[TestAssets alloc] init];
    FritzVisionImage *visionImage = [testAssets fritzImageForTestImage:TestImageCat];
    FritzVisionPetSegmentationModelSmall *model = [FritzVisionPetSegmentationModelSmallObjc model];
    FritzVisionSegmentationModelOptions *options = [[FritzVisionSegmentationModelOptions alloc] init];

    XCTestExpectation *fritzPredictExpectation = [self expectationWithDescription:@"Fritz Prediction Finished"];
    [model predict:visionImage options:options completion:^(FritzVisionSegmentationResult * _Nullable result, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(result);
        UIImage* image = [result buildSingleClassMask:FritzVisionPetClass.pet clippingScoresAbove:.5 zeroingScoresBelow:.5 maxAlpha:255 resize:true color:nil blurRadius:0];
        XCTAssertNotNil(image);
        [fritzPredictExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


- (void)testRunOutdoorSegmentationModel {
    TestAssets *testAssets = [[TestAssets alloc] init];
  
    FritzVisionImage *visionImage = [testAssets fritzImageForTestImage:TestImageMe];
    FritzVisionOutdoorSegmentationModelSmall *model = [FritzVisionOutdoorSegmentationModelSmallObjc model];
    FritzVisionSegmentationModelOptions *options = [[FritzVisionSegmentationModelOptions alloc] init];

    XCTestExpectation *fritzPredictExpectation = [self expectationWithDescription:@"Fritz Prediction Finished"];
    [model predict:visionImage options:options completion:^(FritzVisionSegmentationResult * _Nullable result, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(result);

      UIImage* image = [result buildSingleClassMask:FritzVisionOutdoorClass.sky clippingScoresAbove:.5 zeroingScoresBelow:.5 maxAlpha:255 resize:true color:nil blurRadius:0];
      XCTAssertNotNil(image);
      [fritzPredictExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


- (void)testFetchModel {

    XCTestExpectation *fritzPredictExpectation = [self expectationWithDescription:@"Fritz Prediction Finished"];
    [FritzVisionPeopleSegmentationModelAccurate fetchModelWithCompletionHandler:^(FritzVisionPeopleSegmentationModelAccurate * _Nullable result, NSError * _Nullable error) {
        [fritzPredictExpectation fulfill];

    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testMaskFromResult {
  TestAssets *testAssets = [[TestAssets alloc] init];
  FritzVisionImage *visionImage = [testAssets fritzImageForTestImage:TestImageTennis];
  FritzVisionPeopleSegmentationModelFast *model = [FritzVisionPeopleSegmentationModelFastObjc model];
  FritzVisionSegmentationModelOptions *options = [[FritzVisionSegmentationModelOptions alloc] init];

  XCTestExpectation *fritzPredictExpectation = [self expectationWithDescription:@"Fritz Prediction Finished"];
  [model predict:visionImage options:options completion:^(FritzVisionSegmentationResult * _Nullable result, NSError * _Nullable error) {
    XCTAssertNil(error);
    XCTAssertNotNil(result);

    UIImage *maskImage = [result buildSingleClassMask:[FritzVisionPeopleClass person] clippingScoresAbove:.5 zeroingScoresBelow:.5 maxAlpha:255  resize:true color:nil blurRadius: 0];

    XCTAssertEqual(maskImage.size.width, visionImage.size.width);
    XCTAssertEqual(maskImage.size.height, visionImage.size.height);

    UIImage *clipMaskImage = [visionImage maskWithImage:maskImage removingPixelsIn:FritzSegmentationRegionForeground samplingMethod:ResizeSamplingMethodAffine context:nil];
    XCTAssertNotNil(clipMaskImage);
    [fritzPredictExpectation fulfill];
  }];

   [self waitForExpectationsWithTimeout:5.0 handler:nil];

}

- (void)testBuildImageFromMask {

  TestAssets *testAssets = [[TestAssets alloc] init];
  UIImage *uiImage = [testAssets imageForTestImage:TestImageTennis];
  FritzVisionImage *visionImage = [[FritzVisionImage alloc] initWithImage: uiImage];
  FritzVisionPeopleSegmentationModelFast *model = [FritzVisionPeopleSegmentationModelFastObjc model];
  FritzVisionSegmentationModelOptions *options = [[FritzVisionSegmentationModelOptions alloc] init];

  XCTestExpectation *fritzPredictExpectation = [self expectationWithDescription:@"Fritz Prediction Finished"];
  [model predict:visionImage options:options completion:^(FritzVisionSegmentationResult * _Nullable result, NSError * _Nullable error) {
    XCTAssertNil(error);
    XCTAssertNotNil(result);
    UIImage *maskImage = [result buildSingleClassMask:[FritzVisionPeopleClass person] clippingScoresAbove:.5 zeroingScoresBelow:.5 maxAlpha:255  resize:true color:nil blurRadius: 0];

    XCTAssertEqual(maskImage.size.width, uiImage.size.width);
    XCTAssertEqual(maskImage.size.height, uiImage.size.height);

    CIImage *maskCI = maskImage.CIImage;
    CIImage *imageCI = [[CIImage alloc] initWithCGImage:uiImage.CGImage];

    CIImage *empty = [CIImage emptyImage];

    CIFilter *filter = [CIFilter filterWithName:@"CIBlendWithAlphaMask"];
    [filter setValue:imageCI forKey:kCIInputImageKey];
    [filter setValue:maskCI forKey:kCIInputMaskImageKey];
    [filter setValue:empty forKey:kCIInputBackgroundImageKey];

    struct CGImage *cgImage = [[FritzVisionImage sharedContext]
                               createCGImage:[filter outputImage]
                               fromRect:[maskCI extent]];

    UIImage *cutOutImage = [[UIImage alloc]
                            initWithCGImage:cgImage];
    XCTAssertNotNil(cutOutImage);
    XCTAssertEqual(cutOutImage.size.width, uiImage.size.width);
    XCTAssertEqual(cutOutImage.size.height, uiImage.size.height);
    [fritzPredictExpectation fulfill];
  }];

  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
