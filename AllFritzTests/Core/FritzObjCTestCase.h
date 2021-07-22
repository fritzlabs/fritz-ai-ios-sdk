//
//  ObjCFritzTestCase.h
//  Fritz
//
//  Created by Christopher Kelly on 2/11/19.
//  Copyright © 2019 Fritz Labs Incorporated. All rights reserved.
//

#ifndef FritzObjCTestCase_h
#define FritzObjCTestCase_h

#import <XCTest/XCTest.h>
#import "TestModels+Fritz.h"


@interface FritzObjCTestCase: XCTestCase
{
@public ObjCDigits* model;
}

@property (nonatomic, readwrite) ObjCDigits* model;

@end



#endif /* FritzObjCTestCase_h */
