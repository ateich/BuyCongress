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
    
    return self;
}

-(NSArray *)getLawmakersFromZip:(int)zip{
    return nil;
}

-(NSArray *)getAllLawmakers{
    NSData *data = [self getRequest:[NSString stringWithFormat:@"%@%@%@%@", sunlightURL, @"/legislators", sunlightKey, @"&per_page=all"]];
    
    NSError *error;
    NSArray *jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if(error){
        NSLog(@"ERROR PARSING JSON FROM GET ALL LAWMAKERS: %@", error);
        return nil;
    }
    
    return jsonObjects;
}

//CONSIDER MOVING TO ASYNC TO PREVENT UI LOCKING
-(NSData *)getRequest:(NSString*)url{
    NSLog(@"URL: %@", url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
//    [request setHTTPMethod:@"GET"];
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(!error){
        return data;
    } else{
        NSLog(@"ERROR: %@", [error description]);
    }
    return nil;
}

//FOR ASYNC CALLS, if needed
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
//    _responseData = [[NSMutableData alloc] init];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
//    [_responseData appendData:data];
//}
//
//- (void)connection:(NSURLConnection *)connection{
//    
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    //PARSE RESPONSE DATA HERE
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    // Uh oh...
//}
//
//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
//    return nil;
//}

@end
