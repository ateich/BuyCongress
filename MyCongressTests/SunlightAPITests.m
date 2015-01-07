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

@interface SunlightAPITests : XCTestCase

@end

@implementation SunlightAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianData:) name:politicianDataChanged object:nil];
    XCTestExpectation *expectPoliticianDataToBeReturned = [self expectationForNotification:politicianDataChanged object:nil handler:^XCNotificationExpectation(NSNotification *notification){
        NSLog(@"TEST GET LAWMAKER RETURNED");
        NSDictionary *userInfo = [notification userInfo];
        NSArray *politicianData = [[userInfo objectForKey:@"allPoliticiansResponse"] objectForKey:@"results"];
        if(politicianData.count > 0){
            [expectPoliticianDataToBeReturned fulfill];
        };
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)didReceivePoliticianData:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSArray *politicianData = [[userInfo objectForKey:@"allPoliticiansResponse"] objectForKey:@"results"];
}
@end
