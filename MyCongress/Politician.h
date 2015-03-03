//
//  Politician.h
//  MyCongress
//
//  Created by HackReactor on 1/2/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Politician : NSObject

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *gender;

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *twitter;
@property (nonatomic, copy) NSString *website;
@property (nonatomic, copy) NSString *youtubeID;

@property (nonatomic, copy) NSString *party;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *bioguideID;

@end
