////
////  PoseTestsObjectiveC.m
////  AllFritzTests
////
////  Created by Christopher Kelly on 2/11/19.
////  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//
//#import <XCTest/XCTest.h>
//#import <FritzVision/FritzVision.h>
//#import <FritzVisionHumanPoseModelFast/FritzVisionHumanPoseModelFast.h>
//#import "FritzObjCTestCase.h"
//#import "AllFritzTests-Swift.h"
//
//@interface FritzVisionPoseModelObjcTests: FritzObjCTestCase
//@end
//
//
//@implementation FritzVisionPoseModelObjcTests
//
//
//- (void)testRunModel {
//    TestAssets *testAssets = [[TestAssets alloc] init];
//    UIImage *uiImage = [testAssets imageForTestImage:TestImageSkiing];
//
//    FritzVisionHumanPoseModelFast *model = [FritzVisionHumanPoseModelFastObjc model];
//
//    FritzVisionPoseModelOptions *options = [[FritzVisionPoseModelOptions alloc] init];
//    FritzVisionImage* image = [[FritzVisionImage alloc] initWithImage:uiImage];
//
//    XCTestExpectation *fritzPredictExpectation = [self expectationWithDescription:@"Fritz Prediction Finished"];
//    [model predictWithImage:image options:options completion:^(FritzVisionPoseResult * _Nullable result, NSError * _Nullable error) {
//        XCTAssertNil(error);
//        XCTAssertNotNil(result);
//        FritzPose * _Nullable pose = [result pose];
//        XCTAssertNotNil(pose);
//        UIImage* resultImage = [image drawPose:pose meetingThreshold:0.5];
//        XCTAssertNotNil(resultImage);
//        [fritzPredictExpectation fulfill];
//    }];
//
//    [self waitForExpectationsWithTimeout:5.0 handler:nil];
//}
//
//@end
