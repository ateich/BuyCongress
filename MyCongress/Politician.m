//
//  Politician.m
//  MyCongress
//
//  Created by HackReactor on 1/2/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "Politician.h"

@implementation Politician

@synthesize firstName;
@synthesize lastName;
@synthesize gender;

@synthesize email;
@synthesize phone;
@synthesize twitter;
@synthesize website;
@synthesize youtubeID;

@synthesize party;
@synthesize title;
@synthesize state;
@synthesize bioguideID;

-(NSString*)description{
    return [NSString stringWithFormat:@"Politican:\nName: %@ %@\nGender: %@\nEmail: %@\nPhone: %@\nTwitterID: %@\nWebsite: %@\nYouTubeID: %@\nParty: %@\nTitle: %@\nState: %@\nBioGuideID: %@\n\n", firstName, lastName, gender, email, phone, twitter, website, youtubeID, party, title, state, bioguideID];
}

@end
