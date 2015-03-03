//
//  SunlightFactory.m
//  MyCongress
//
//  Created by HackReactor on 1/2/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "SunlightFactory.h"
#import "Tokens.h"

NSString *sunlightKey;
NSString *sunlightURL = @"http://congress.api.sunlightfoundation.com";
NSString *transparencyURL = @"http://transparencydata.com/api/1.0";
NSMutableDictionary *sectorCodes;
NSMutableDictionary *asyncDataStore;

NSMutableDictionary *reverseConnectionLookup;
NSMutableDictionary *entityQueryStore;
NSMutableDictionary *entityLawmakerIdStore;


@implementation SunlightFactory

-(id)init{
    self = [super init];
    
    sunlightKey = [NSString stringWithFormat:@"?apikey=%@", [Tokens getSunlightToken]];

    sectorCodes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
       @"Agribusiness", @"A",
       @"Communications/Electronics", @"B",
       @"Construction", @"C",
       @"Defense", @"D",
       @"Energy/Natural Resources", @"E",
       @"Finance/Insurance/Real Estate", @"F",
       @"Health", @"H",
       @"Lawyers and Lobbyists", @"K",
       @"Transportation", @"M",
       @"Misc. Business", @"N",
       @"Ideology/Single Issue", @"Q",
       @"Labor", @"P",
       @"Other", @"W",
       @"Unknown", @"Y",
       @"Administrative Use", @"Z",
       nil];
    
    asyncDataStore = [[NSMutableDictionary alloc] init];
    reverseConnectionLookup = [[NSMutableDictionary alloc] init];
    entityQueryStore = [[NSMutableDictionary alloc] init];
    entityLawmakerIdStore = [[NSMutableDictionary alloc] init];
    
    return self;
}

-(void)getAllLawmakers{
    [self getRequest:[NSString stringWithFormat:@"%@%@%@%@", sunlightURL, @"/legislators", sunlightKey, @"&per_page=all"] withCallingMethod:@"getAllLawmakers"];
}

-(void)getLawmakersByZipCode:(NSString*)zip{
    [self getRequest:[NSString stringWithFormat:@"%@%@%@%@%@", sunlightURL, @"/legislators/locate", sunlightKey, @"&zip=", zip] withCallingMethod:@"getLawmakersByZipCode"];
}

-(void)getLawmakersByLatitude:(NSString*)latitude andLongitude:(NSString*)longitude{
    [self getRequest:[NSString stringWithFormat:@"%@%@%@%@%@%@%@", sunlightURL, @"/legislators/locate", sunlightKey, @"&latitude=", latitude, @"&longitude=", longitude] withCallingMethod:@"getLawmakersByLatitudeAndLongitude"];
}

-(void)getTopDonorsForLawmaker:(NSString*)lawmakerID {
    NSString *url = [NSString stringWithFormat:@"%@/aggregates/pol/%@/contributors.json%@", transparencyURL, lawmakerID, sunlightKey];
    [self getRequest:url withCallingMethod:@"getTopDonorsForLawmaker"];
}

-(void)getTopDonorIndustriesForLawmaker:(NSString*)lawmakerID{
    NSString *url = [NSString stringWithFormat:@"%@/aggregates/pol/%@/contributors/industries.json%@", transparencyURL, lawmakerID, sunlightKey];
    [self getRequest:url withCallingMethod:@"getTopDonorIndustriesForLawmaker"];
}

-(void)getTopDonorSectorsForLawmaker:(NSString*)lawmakerID{
    NSString *url = [NSString stringWithFormat:@"%@/aggregates/pol/%@/contributors/sectors.json%@", transparencyURL, lawmakerID, sunlightKey];
    [self getRequest:url withCallingMethod:@"getTopDonorSectorsForLawmaker"];
}

-(void)searchForEntity:(NSString*)entity{
    entity = [entity stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *url = [NSString stringWithFormat:@"%@/entities.json%@&search=%@", transparencyURL, sunlightKey, entity];
    [self getRequest:url withCallingMethod:@"searchForEntity"];
}

-(void)getLawmakerTransparencyIDFromFirstName:(NSString*)first andLastName:(NSString*)last{
    
    //remove accents from names
    first = [[NSString alloc] initWithData:[first dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] encoding:NSASCIIStringEncoding];
    last = [[NSString alloc] initWithData:[last dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] encoding:NSASCIIStringEncoding];
    
    NSString *url = [NSString stringWithFormat:@"%@/entities.json%@&search=%@+%@&type=politician", transparencyURL, sunlightKey, first, last];
    [self getRequest:url withCallingMethod:@"getTransparencyID"];
}

-(void)getContributionsFromOrganization:(NSString*)organization ToPolitician:(NSString*)politician{
    
    //Remove spaces from query
    politician = [politician stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    organization = [organization stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSString *url = [NSString stringWithFormat:@"%@/contributions.json%@&contributor_ft=%@&recipient_ft=%@", transparencyURL, sunlightKey, organization, politician];
    [self getRequest:url withCallingMethod:@"getContributionsFromOrganizationToPolitician"];
}

#pragma mark - Async request helper functions
-(void)getRequest:(NSString*)url withCallingMethod:(NSString*)callingMethod{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if([callingMethod isEqualToString:@"searchForEntity"]){
        long wordsInQuery = [[url componentsSeparatedByString:@"+"] count] -1;
        entityQueryStore[[connection description]] = [NSNumber numberWithLong:wordsInQuery];
    } else if([callingMethod isEqualToString:@"getTopDonorIndustriesForLawmaker"]){
        
        //get politician id from url
        NSString *lawmakerID = [[url componentsSeparatedByString:@"http://transparencydata.com/api/1.0/aggregates/pol/"] objectAtIndex:1];
        lawmakerID = [[lawmakerID componentsSeparatedByString:@"/"] objectAtIndex:0];
        
        entityLawmakerIdStore[[connection description]] = lawmakerID;
    }
    
    reverseConnectionLookup[[connection description]] = callingMethod;
}

#pragma mark - NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(!asyncDataStore[[connection description]]){
        asyncDataStore[[connection description]] = [[NSMutableData alloc] init];
    }
    [asyncDataStore[[connection description]] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSError *error;
    NSArray *jsonObjects = [NSJSONSerialization JSONObjectWithData:asyncDataStore[[connection description]]options:kNilOptions error:&error];
    
    if(error){
        [self sendTimeoutNotification:connection withTitle:@"Politician Data Not Available" andMessage:@"The source of politician data is currently offline. Please try again later."];
        return;
    }
    
    NSDictionary *userInfo = @{@"results": jsonObjects};
    asyncDataStore[[connection description]] = [[NSMutableData alloc] init];
    
    NSString *methodName = reverseConnectionLookup[[connection description]];
    NSString *firstCapChar = [[methodName substringToIndex:1] capitalizedString];
    NSString *cappedString = [methodName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
    
    NSString *postNotificationName = [NSString stringWithFormat:@"SunlightFactoryDidReceive%@Notification", cappedString];
    
    if([reverseConnectionLookup[[connection description]] isEqualToString:@"searchForEntity"]){
        NSNumber *queryWordCount = entityQueryStore[[connection description]];
        if(jsonObjects){
            NSMutableDictionary *extraInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
            extraInfo[@"numberOfWordsInQuery"] = queryWordCount;
            userInfo = extraInfo;
        }
    } else if([reverseConnectionLookup[[connection description]] isEqualToString:@"getTopDonorIndustriesForLawmaker"]){
        if(jsonObjects){
            NSMutableDictionary *extraInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
            extraInfo[@"callingLawmakerId"] = entityLawmakerIdStore[[connection description]];
            userInfo = extraInfo;
        }
    } else if([reverseConnectionLookup[[connection description]] isEqualToString:@"getContributionsFromOrganizationToPolitician"]){
        if(jsonObjects){
            //split URL to get contributor_ft & recipient_ft
            NSString *urlPath = [[[connection currentRequest] URL] description];
            urlPath = [[urlPath componentsSeparatedByString:@"contributor_ft="] objectAtIndex:1];
            NSArray *parts = [urlPath componentsSeparatedByString:@"&recipient_ft="];
            NSString *contributor_ft = [parts[0] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            NSString *recipient_ft = [parts[1] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            
            NSMutableDictionary *extraInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
            extraInfo[@"politician"] = recipient_ft;
            extraInfo[@"organization"] = contributor_ft;
            userInfo = extraInfo;
        }
    }
    
    if(jsonObjects){
        [[NSNotificationCenter defaultCenter] postNotificationName:postNotificationName object:self userInfo:userInfo];
    }
}

-(void)sendTimeoutNotification:(NSURLConnection*)connection withTitle:(NSString*)title andMessage:(NSString*)message{
    NSDictionary *userInfo;
    
    if(title && message){
        userInfo = @{@"title":title, @"message":message};
    }
    
    //Send notification that tells calling view that a timeout has occurred for a call for essential data
    if([reverseConnectionLookup[[connection description]] isEqualToString:@"getTransparencyID"] ||
       [reverseConnectionLookup[[connection description]] isEqualToString:@"getTopDonorsForLawmaker"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SunlightFactoryDidReceiveConnectionTimedOutForDonationsNotification" object:self userInfo:userInfo];
    } else if([reverseConnectionLookup[[connection description]] isEqualToString:@"getLawmakersByLatitudeAndLongitude"] ||
              [reverseConnectionLookup[[connection description]] isEqualToString:@"getLawmakersByZipCode"]){
        NSLog(@"timed out for search");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SunlightFactoryDidReceiveConnectionTimedOutForSearchNotification" object:self userInfo:userInfo];
    } else if([[reverseConnectionLookup objectForKey:[connection description]] isEqualToString:@"getAllLawmakers"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SunlightFactoryDidReceiveConnectionTimedOutForAllLawmakersNotification" object:self userInfo:userInfo];
    }
}

-(void)sendTimeoutNotification:(NSURLConnection*)connection{
    [self sendTimeoutNotification:connection withTitle:nil andMessage:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"[SunlightFactory.m] ERROR: Connection Failed - %@", connection);
    
    NSLog(@"%@", reverseConnectionLookup[[connection description]]);
    [self sendTimeoutNotification:connection];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    //Do not cache response
    return nil;
}

-(NSString*)convertSectorCode:(NSString*)code{
    return [sectorCodes objectForKey:code];
}

@end
