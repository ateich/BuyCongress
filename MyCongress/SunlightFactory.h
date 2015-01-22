//
//  SunlightFactory.h
//  MyCongress
//
//  Created by HackReactor on 1/2/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunlightFactory : NSObject<NSURLConnectionDelegate>{
    NSMutableData *_responseData;
}

-(void)getAllLawmakers;
-(void)getLawmakersByZipCode:(NSString*)zip;
-(NSString*)convertSectorCode:(NSString*)code;
-(void)getTopDonorsForLawmaker:(NSString*)lawmakerID;
-(void)getTopDonorIndustriesForLawmaker:(NSString*)lawmakerID;
-(void)getTopDonorSectorsForLawmaker:(NSString*)lawmakerID;
-(void)getLawmakersByLatitude:(NSString*)latitude andLongitude:(NSString*)longitude;
-(void)getLawmakerTransparencyIDFromFirstName:(NSString*)first andLastName:(NSString*)last;

@end
