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
NSMutableDictionary *asyncCalls;
NSMutableDictionary *asyncDataStore;

NSMutableDictionary *reverseConnectionLookup;


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
    
    asyncCalls = [[NSMutableDictionary alloc] init];
    asyncDataStore = [[NSMutableDictionary alloc] init];
    reverseConnectionLookup = [[NSMutableDictionary alloc] init];
    
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
//    NSLog(@"URL: %@", url);
    [self getRequest:url withCallingMethod:@"getTopDonorIndustriesForLawmaker"];
}

-(void)getTopDonorSectorsForLawmaker:(NSString*)lawmakerID{
    NSString *url = [NSString stringWithFormat:@"%@/aggregates/pol/%@/contributors/sectors.json%@", transparencyURL, lawmakerID, sunlightKey];
//    NSLog(@"URL: %@", url);
    [self getRequest:url withCallingMethod:@"getTopDonorSectorsForLawmaker"];
}

-(void)searchForEntity:(NSString*)entity{
    entity = [entity stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *url = [NSString stringWithFormat:@"%@/entities.json%@&search=%@", transparencyURL, sunlightKey, entity];
//    NSLog(@"URL: %@", url);
    [self getRequest:url withCallingMethod:@"searchForEntity"];
}

-(void)getLawmakerTransparencyIDFromFirstName:(NSString*)first andLastName:(NSString*)last{
    NSString *url = [NSString stringWithFormat:@"%@/entities.json%@&search=%@+%@&type=politician", transparencyURL, sunlightKey, first, last];
//    NSLog(@"URL: %@", url);
    [self getRequest:url withCallingMethod:@"getTransparencyID"];
}

#pragma mark - Async request helper functions
-(void)getRequest:(NSString*)url withCallingMethod:(NSString*)callingMethod{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [asyncCalls setObject:connection forKey:callingMethod];
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
//    NSLog(@"%@", postNotificationName);
    
    if(jsonObjects){
        [[NSNotificationCenter defaultCenter] postNotificationName:postNotificationName object:self userInfo:userInfo];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Uh oh...
    NSLog(@"[SunlightFactory.m] ERROR: Connection Failed - %@", error);
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    //Do not cache response
    return nil;
}

-(NSString*)convertSectorCode:(NSString*)code{
    return [sectorCodes objectForKey:code];
}

@end
