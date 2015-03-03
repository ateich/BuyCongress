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
#import "Tokens.h"

NSString *TRANSPARENCY_ID;


@interface SunlightAPITests : XCTestCase{
    SunlightFactory *api;
}

@end

@implementation SunlightAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    api = [[SunlightFactory alloc] init];
    TRANSPARENCY_ID = [Tokens getSunlightToken];
    //42ccd9758603419ba38a2546d96a0f02
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    XCTAssert(YES, @"Pass");
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

-(void)testGetAllLawmakers {
    NSString *politicianDataChanged = @"SunlightFactoryDidReceiveGetAllLawmakersNotification";
    
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:politicianDataChanged object:nil];
    [[observerMock expect] notificationWithName:politicianDataChanged object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
        NSMutableDictionary *value = [userInfo objectForKey:@"results"];
        if(value && [value objectForKey:@"results"]){
            return YES;
        } else {
            return NO;
        }
    }]];
    
    [api getAllLawmakers];
    [self waitForVerifiedMock:observerMock delay:3];
}

-(void)testGetLawmakersByZipCode {
    NSString *politicianDataChanged = @"SunlightFactoryDidReceiveGetLawmakersByZipCodeNotification";
    
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:politicianDataChanged object:nil];
    [[observerMock expect] notificationWithName:politicianDataChanged object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
        NSMutableDictionary *value = [userInfo objectForKey:@"results"];
        if(value && [value objectForKey:@"results"]){
            return YES;
        } else {
            return NO;
        }
    }]];
    
    [api getLawmakersByZipCode:@"01085"];
    [self waitForVerifiedMock:observerMock delay:3];
}

-(void)XtestGetLawmakersByLocation {
    NSString *politicianDataChanged = @"SunlightFactoryDidReceiveGetLawmakersByLatitudeAndLongitudeNotification";
    
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:politicianDataChanged object:nil];
    [[observerMock expect] notificationWithName:politicianDataChanged object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
        NSMutableDictionary *value = [userInfo objectForKey:@"results"];
        if(value && [value objectForKey:@"results"]){
            return YES;
        } else {
            return NO;
        }
    }]];
    
    [api getLawmakersByLatitude:@"" andLongitude:@""];
    [self waitForVerifiedMock:observerMock delay:3];
}

-(void)testGetTopDonorsForLawmaker{
    NSString *politicianDataChanged = @"SunlightFactoryDidReceiveGetTopDonorsForLawmakerNotification";
    
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:politicianDataChanged object:nil];
    [[observerMock expect] notificationWithName:politicianDataChanged object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
        NSMutableDictionary *value = [userInfo objectForKey:@"results"];
        if(value){
            return YES;
        } else {
            return NO;
        }
    }]];
    NSLog(@"transparency test id: %@", TRANSPARENCY_ID);
    [api getTopDonorsForLawmaker:TRANSPARENCY_ID];
    [self waitForVerifiedMock:observerMock delay:3];
}

-(void)testGetTopDonorIndustriesForLawmaker{
    NSString *politicianDataChanged = @"SunlightFactoryDidReceiveGetTopDonorIndustriesForLawmakerNotification";
    
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:politicianDataChanged object:nil];
    [[observerMock expect] notificationWithName:politicianDataChanged object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
        NSMutableDictionary *value = [userInfo objectForKey:@"results"];
        if(value){
            return YES;
        } else {
            return NO;
        }
    }]];
    
    [api getTopDonorIndustriesForLawmaker:TRANSPARENCY_ID];
    [self waitForVerifiedMock:observerMock delay:3];
}

-(void)testGetTransparencyID{
    NSString *politicianDataChanged = @"SunlightFactoryDidReceiveGetTransparencyIDNotification";
    
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:politicianDataChanged object:nil];
    [[observerMock expect] notificationWithName:politicianDataChanged object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
        NSMutableDictionary *value = [userInfo objectForKey:@"results"];
        if(value){
            return YES;
        } else {
            return NO;
        }
    }]];
    
    [api getLawmakerTransparencyIDFromFirstName:@"Elizabeth" andLastName:@"Warren"];
    [self waitForVerifiedMock:observerMock delay:3];
}

-(void)testGetTopDonorSectorsForLawmaker{
    NSString *politicianDataChanged = @"SunlightFactoryDidReceiveGetTopDonorSectorsForLawmakerNotification";
    
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:politicianDataChanged object:nil];
    [[observerMock expect] notificationWithName:politicianDataChanged object:[OCMArg any] userInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
        NSMutableDictionary *value = [userInfo objectForKey:@"results"];
        if(value){
            return YES;
        } else {
            return NO;
        }
    }]];
    
    [api getTopDonorSectorsForLawmaker:TRANSPARENCY_ID];
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
