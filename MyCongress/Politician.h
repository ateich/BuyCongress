//
//  Politician.h
//  MyCongress
//
//  Created by HackReactor on 1/2/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Politician : NSObject {
    NSString *firstName;
    NSString *lastName;
    NSString *gender;
    
    NSString *email;
    NSString *phone;
    NSString *twitter;
    NSString *website;
    NSString *youtubeID;
    
    NSString *party;
    NSString *title;
    NSString *state;
}

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *gender;

@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *twitter;
@property (nonatomic, retain) NSString *website;
@property (nonatomic, retain) NSString *youtubeID;

@property (nonatomic, retain) NSString *party;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *state;

@end
