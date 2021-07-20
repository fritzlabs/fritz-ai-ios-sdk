//
//  ObjCFritzTestCase.m
//  AllFritzTests
//
//  Created by Christopher Kelly on 2/11/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

#import "FritzObjCTestCase.h"


@implementation FritzObjCTestCase

@synthesize model=_model;

- (void) setUp {
    FritzSession *session = [[FritzSession alloc] initWithAppToken:@"fritz-test-app-token" apiUrl:@"http://localhost:port" namespace:@"Test"];

    FritzConfiguration* configuration = [[FritzConfiguration alloc] initWithSession:session];
    [FritzCore configureWith:configuration];
    model = [ObjCDigits new];
    [super setUp];
}

@end
