//
//  SunlightAPITests.m
//  MyCongress
//
//  Created by HackReactor on 1/6/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SunlightFactory.h"
#import "OCMock.h"

@interface SunlightAPITests : XCTestCase{
    SunlightFactory *api;
}

@end

@implementation SunlightAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    api = [[SunlightFactory alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)testGetAllLawmakers {
    NSString *politicianDataChanged = @"SunlightFactoryDidReceivePoliticianDataNotification";
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianData:) name:politicianDataChanged object:nil];
    
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:politicianDataChanged object:nil];
    [[observerMock expect] notificationWithName:politicianDataChanged object:[OCMArg any] userInfo:[OCMArg any]];
    
    [api getAllLawmakers];
    [self waitForVerifiedMock:observerMock delay:3];
}

- (void)waitForVerifiedMock:(OCMockObject *)inMock delay:(NSTimeInterval)inDelay {
    NSTimeInterval i = 0;
    while (i < inDelay){
        @try{
            [inMock verify];
            return;
        }
        @catch (NSException *e) {}
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        i+=0.5;
    }
    [inMock verify];
}
@end
