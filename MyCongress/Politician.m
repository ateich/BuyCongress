//
//  Politician.m
//  MyCongress
//
//  Created by HackReactor on 1/2/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "Politician.h"

@implementation Politician

-(NSString*)description{
    return [NSString stringWithFormat:@"Politican:\nName: %@ %@\nGender: %@\nEmail: %@\nPhone: %@\nTwitterID: %@\nWebsite: %@\nYouTubeID: %@\nParty: %@\nTitle: %@\nState: %@\nBioGuideID: %@\n\n", _firstName, _lastName, _gender, _email, _phone, _twitter, _website, _youtubeID, _party, _title, _state, _bioguideID];
}

-(void)setParty:(NSString *)party{
    _party = party;
    _partyAbbreviated = [[party substringToIndex:1] uppercaseString];
}

@end
