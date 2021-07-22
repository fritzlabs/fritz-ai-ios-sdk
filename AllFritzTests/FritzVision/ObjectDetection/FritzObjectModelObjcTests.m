//
//  FritzVisionLabelModelTestsObjc.m
//  AllFritzTests
//
//  Created by Christopher Kelly on 1/21/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <XCTest/XCTest.h>
#import <FritzVision/FritzVision.h>

@interface FritzVisionObjectModelObjcTests: XCTestCase
@end


@implementation FritzVisionObjectModelObjcTests


- (void)testObjectPropertiesAreAccessible {
    FritzVisionLabel *label = [[FritzVisionLabel alloc] initWithLabel:@"Im a label!" confidence:0.5];
    BoundingBox* boundingBox = [[BoundingBox alloc] initWithYMin:0.0 xMin:0.0 yMax:0.0 xMax:0.0];
    FritzVisionObject *object = [[FritzVisionObject alloc] initWithLabel:label boundingBox:boundingBox bounds:CGSizeZero];

    XCTAssertEqualObjects([object boundingBox], boundingBox);
    XCTAssertEqualObjects([object label] ,@"Im a label!");
}
@end
