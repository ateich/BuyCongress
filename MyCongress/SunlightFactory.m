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
        [entityQueryStore setObject:[NSNumber numberWithLong:wordsInQuery] forKey:[connection description]];
    } else if([callingMethod isEqualToString:@"getTopDonorIndustriesForLawmaker"]){
        
        //get politician id from url
        //http://transparencydata.com/api/1.0/aggregates/pol/c343c50275e6481e9b7b0c9c0cc430e5/contributors/industries.json?apikey=d5ac2a8391d94345b8e93d5c69dd8739
        NSString *lawmakerID = [[url componentsSeparatedByString:@"http://transparencydata.com/api/1.0/aggregates/pol/"] objectAtIndex:1];
        lawmakerID = [[lawmakerID componentsSeparatedByString:@"/"] objectAtIndex:0];
        
        [entityLawmakerIdStore setObject:lawmakerID forKey:[connection description]];
    }
    
    [reverseConnectionLookup setObject:callingMethod forKey:[connection description]];
}

#pragma mark - NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(![asyncDataStore objectForKey:[connection description]]){
        [asyncDataStore setObject:[[NSMutableData alloc] init] forKey:[connection description]];
    }
    [[asyncDataStore objectForKey:[connection description]] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSError *error;
    NSArray *jsonObjects = [NSJSONSerialization JSONObjectWithData:[asyncDataStore objectForKey:[connection description]]options:kNilOptions error:&error];
    NSDictionary *userInfo = @{@"results": jsonObjects};
    [asyncDataStore setObject:[[NSMutableData alloc] init] forKey:[connection description]];
    
    NSString *methodName = [reverseConnectionLookup objectForKey:[connection description]];
    NSString *firstCapChar = [[methodName substringToIndex:1] capitalizedString];
    NSString *cappedString = [methodName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
    
    NSString *postNotificationName = [NSString stringWithFormat:@"SunlightFactoryDidReceive%@Notification", cappedString];
    
    if([[reverseConnectionLookup objectForKey:[connection description]] isEqualToString:@"searchForEntity"]){
        NSNumber *queryWordCount = [entityQueryStore objectForKey:[connection description]];
        if(jsonObjects){
            NSMutableDictionary *extraInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
            [extraInfo setObject:queryWordCount forKey:@"numberOfWordsInQuery"];
            userInfo = extraInfo;
        }
    } else if([[reverseConnectionLookup objectForKey:[connection description]] isEqualToString:@"getTopDonorIndustriesForLawmaker"]){
        if(jsonObjects){
            NSMutableDictionary *extraInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
            [extraInfo setObject:[entityLawmakerIdStore objectForKey:[connection description]] forKey:@"callingLawmakerId"];
            userInfo = extraInfo;
        }
    } else if([[reverseConnectionLookup objectForKey:[connection description]] isEqualToString:@"getContributionsFromOrganizationToPolitician"]){
        if(jsonObjects){
            
            //split URL to get contributor_ft & recipient_ft
            NSString *urlPath = [[[connection currentRequest] URL] description];
            urlPath = [[urlPath componentsSeparatedByString:@"contributor_ft="] objectAtIndex:1];
            NSArray *parts = [urlPath componentsSeparatedByString:@"&recipient_ft="];
            NSString *contributor_ft = [[parts objectAtIndex:0] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            NSString *recipient_ft = [[parts objectAtIndex:1] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            
            NSMutableDictionary *extraInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
            [extraInfo setObject:recipient_ft forKey:@"politician"];
            [extraInfo setObject:contributor_ft forKey:@"organization"];
            userInfo = extraInfo;
        }
    }
    
    if(jsonObjects){
        [[NSNotificationCenter defaultCenter] postNotificationName:postNotificationName object:self userInfo:userInfo];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"[SunlightFactory.m] ERROR: Connection Failed - %@", connection);
    
    NSLog(@"%@", [reverseConnectionLookup objectForKey:[connection description]]);
    
    //Send notification that tells calling view that a timeout has occurred for a call for essential data
    if([[reverseConnectionLookup objectForKey:[connection description]] isEqualToString:@"getTransparencyID"] || [[reverseConnectionLookup objectForKey:[connection description]] isEqualToString:@"getTopDonorsForLawmaker"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SunlightFactoryDidReceiveConnectionTimedOutForDonationsNotification" object:self userInfo:nil];
    } else if([[reverseConnectionLookup objectForKey:[connection description]] isEqualToString:@"getLawmakersByLatitudeAndLongitude"] ||
              [[reverseConnectionLookup objectForKey:[connection description]] isEqualToString:@"getLawmakersByZipCode"]){
        NSLog(@"timed out for search");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SunlightFactoryDidReceiveConnectionTimedOutForSearchNotification" object:self userInfo:nil];
    } else if([[reverseConnectionLookup objectForKey:[connection description]] isEqualToString:@"getAllLawmakers"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SunlightFactoryDidReceiveConnectionTimedOutForAllLawmakersNotification" object:self userInfo:nil];
    }
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    //Do not cache response
    return nil;
}

-(NSString*)convertSectorCode:(NSString*)code{
    return [sectorCodes objectForKey:code];
}

@end
