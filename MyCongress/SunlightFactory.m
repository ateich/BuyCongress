//
//  SunlightFactory.m
//  MyCongress
//
//  Created by HackReactor on 1/2/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "SunlightFactory.h"
NSString *sunlightKey = @"?apikey=d5ac2a8391d94345b8e93d5c69dd8739";
NSString *sunlightURL = @"http://congress.api.sunlightfoundation.com";
NSString *transparencyURL = @"transparencydata.com";
NSMutableDictionary *sectorCodes;
NSMutableDictionary *asyncCalls;
NSMutableDictionary *asyncDataStore;


@implementation SunlightFactory{
    NSString *politicianDataChanged;
}

-(id)init{
    self = [super init];
    
    politicianDataChanged = @"SunlightFactoryDidReceivePoliticianDataNotification";
    
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
    
    asyncCalls = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  nil, @"getAllLawmakers",
                  nil];
    
    asyncDataStore = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  [[NSMutableData alloc] init], @"getAllLawmakers",
                  nil];
    
    return self;
}

-(NSArray *)getLawmakersFromZip:(int)zip{
    return nil;
}

-(NSArray *)getAllLawmakers{
    [self getRequest:[NSString stringWithFormat:@"%@%@%@%@", sunlightURL, @"/legislators", sunlightKey, @"&per_page=all"] withCallingMethod:@"getAllLawmakers"];
    return nil;
}

-(void)getRequest:(NSString*)url withCallingMethod:(NSString*)callingMethod{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [asyncCalls setObject:connection forKey:callingMethod];
}

#pragma mark - NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(connection == asyncCalls[@"getAllLawmakers"]){
        [[asyncDataStore objectForKey:@"getAllLawmakers"] appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    NSArray *jsonObjects;
    
    //Parse JSON data for the given connection
    if(connection == asyncCalls[@"getAllLawmakers"]){
        NSError *error;
        jsonObjects = [NSJSONSerialization JSONObjectWithData:[asyncDataStore objectForKey:@"getAllLawmakers"] options:kNilOptions error:&error];
    } else if(connection == asyncCalls[@"some other connection to be implemented later"]){
        
    } else {
        NSLog(@"[SunlightFactory.m] WARNING: Unexpected connection finished loading - Data will not be parsed");
    }
    
    if(jsonObjects){
        NSDictionary *userInfo = @{@"allPoliticiansResponse": jsonObjects};
        [[NSNotificationCenter defaultCenter] postNotificationName:politicianDataChanged object:self userInfo:userInfo];
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

@end
