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


@implementation SunlightFactory

-(id)init{
    self = [super init];
    
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
    NSLog(@"%@", [NSString stringWithFormat:@"%@%@%@%@", sunlightURL, @"/legislators", sunlightKey, @"&per_page=all"]);
    return nil;
}

-(void)getRequest:(NSString*)url withCallingMethod:(NSString*)callingMethod{
    NSLog(@"URL: %@", url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [asyncCalls setObject:connection forKey:callingMethod];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(connection == asyncCalls[@"getAllLawmakers"]){
        //NSLog(@"JSON: %@ - %@", data, [error description]);
        [[asyncDataStore objectForKey:@"getAllLawmakers"] appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection{
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"connection finished loading");
    if(connection == asyncCalls[@"getAllLawmakers"]){
        //NSLog(@"JSON: %@ - %@", data, [error description]);
        NSError *error;
        NSArray *jsonObjects = [NSJSONSerialization JSONObjectWithData:[asyncDataStore objectForKey:@"getAllLawmakers"] options:kNilOptions error:&error];
        NSLog(@"JSON: %@", jsonObjects);
        
        //DATA IS NOT PARSED AS JSON
        //HOW TO RETURN IT TO THE VIEW?
        // --> OBSERVER MODEL
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Uh oh...
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

@end
