//
//  FritzVisionLabelModelTestsObjc.m
//  AllFritzTests
//
//  Created by Christopher Kelly on 1/21/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <XCTest/XCTest.h>
#import <FritzCore/FritzCore.h>
#import <FritzVision/FritzVision.h>
#import <FritzVisionLabelModelFast/FritzVisionLabelModelFast.h>
#import "AllFritzTests-Swift.h"

@interface FritzVisionLabelModelObjcTests: XCTestCase
@end


@implementation FritzVisionLabelModelObjcTests

- (void)setUp {
    [super setUp];

    FritzSession *session = [[FritzSession alloc] initWithAppToken:@"fritz-test-app-token" apiUrl:@"http://localhost:port" namespace:@"Test"];
    [FritzCore configureWith:[[FritzConfiguration alloc] initWithSession:session]];
}

- (void)testRunLabelModel {
    TestAssets *testAssets = [[TestAssets alloc] init];
    FritzVisionImage *visionImage = [testAssets fritzImageForTestImage:TestImageIndoor];
    FritzVisionLabelModelFast *model = [FritzVisionLabelModelFastObjc model];

    FritzVisionLabelModelOptions *options = [[FritzVisionLabelModelOptions alloc] init];
    options.threshold = 0.1;
    options.numResults = 10;

    XCTestExpectation *fritzPredictExpectation = [self expectationWithDescription:@"Fritz Prediction Finished"];
    [model predict:visionImage options:options completion:^(NSArray<FritzVisionLabel *> * _Nullable results, NSError * _Nullable error) {

        XCTAssertNil(error);
        XCTAssertNotNil(results);
        XCTAssertEqualObjects(@"restaurant",[results[0] label]);
        [fritzPredictExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testLabelsAreAccessible {
    FritzVisionLabel *label = [[FritzVisionLabel alloc] initWithLabel:@"Im a label!" confidence:0.5];
    XCTAssertEqual(@"Im a label!", [label label]);
    XCTAssertEqual(0.5, [label confidence]);
}
@end
