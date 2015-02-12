//
//  ReadabilityFactory.m
//  MyCongress
//
//  Created by HackReactor on 1/23/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "ReadabilityFactory.h"

@implementation ReadabilityFactory{
    NSMutableDictionary *asyncCalls;
    NSMutableDictionary *asyncDataStore;
}

-(id)init{
    self = [super init];

    asyncCalls = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  nil, @"getReadableArticle",
                  nil];
    
    asyncDataStore = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                      [[NSMutableData alloc] init], @"getReadableArticle",
                      nil];
    
    return self;
}

-(void)makeReadableArticleFromUrl:(NSString*)url{
    [self getRequest:url withCallingMethod:@"getReadableArticle"];
}

#pragma mark - Async request helper functions
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
    if(connection == asyncCalls[@"getReadableArticle"]){
        [[asyncDataStore objectForKey:@"getReadableArticle"] appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSArray *jsonObjects;
    NSError *error;
    NSDictionary *userInfo;
    NSString *postNotificationName;
    
    //Parse JSON data for the given connection
    if(connection == asyncCalls[@"getReadableArticle"]){
        jsonObjects = [NSJSONSerialization JSONObjectWithData:[asyncDataStore objectForKey:@"getReadableArticle"] options:kNilOptions error:&error];
        userInfo = @{@"content": jsonObjects};
        [asyncDataStore setObject:[[NSMutableData alloc] init] forKey:@"getReadableArticle"];
        postNotificationName = @"ReadabilityFactoryDidReceiveReadableArticleNotification";
    }
    
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

@end
