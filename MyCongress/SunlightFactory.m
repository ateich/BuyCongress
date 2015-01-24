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
    
    asyncCalls = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  nil, @"getAllLawmakers",
                  nil, @"getTopDonorsForLawmaker",
                  nil, @"getTopDonorIndustriesForLawmaker",
                  nil, @"getTransparencyID",
                  nil, @"getTopDonorSectorsForLawmaker",
                  nil, @"getLawmakersByZipCode",
                  nil, @"getLawmakersByLatitudeAndLongitude",
                  nil];
    
    asyncDataStore = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                      [[NSMutableData alloc] init], @"getAllLawmakers",
                      [[NSMutableData alloc] init], @"getTopDonorsForLawmaker",
                      [[NSMutableData alloc] init], @"getTopDonorIndustriesForLawmaker",
                      [[NSMutableData alloc] init], @"getTransparencyID",
                      [[NSMutableData alloc] init], @"getTopDonorSectorsForLawmaker",
                      [[NSMutableData alloc] init], @"getLawmakersByZipCode",
                      [[NSMutableData alloc] init], @"getLawmakersByLatitudeAndLongitude",
                  nil];
    
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
}

#pragma mark - NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(connection == asyncCalls[@"getAllLawmakers"]){
        [[asyncDataStore objectForKey:@"getAllLawmakers"] appendData:data];
    } else if(connection == asyncCalls[@"getTopDonorsForLawmaker"]){
        [[asyncDataStore objectForKey:@"getTopDonorsForLawmaker"] appendData:data];
    } else if(connection == asyncCalls[@"getTopDonorIndustriesForLawmaker"]){
        [[asyncDataStore objectForKey:@"getTopDonorIndustriesForLawmaker"] appendData:data];
    } else if(connection == asyncCalls[@"getTransparencyID"]){
        [[asyncDataStore objectForKey:@"getTransparencyID"] appendData:data];
    } else if(connection == asyncCalls[@"getTopDonorSectorsForLawmaker"]) {
        [[asyncDataStore objectForKey:@"getTopDonorSectorsForLawmaker"] appendData:data];
    } else if(connection == asyncCalls[@"getLawmakersByZipCode"]){
        [[asyncDataStore objectForKey:@"getLawmakersByZipCode"] appendData:data];
    } else if(connection == asyncCalls[@"getLawmakersByLatitudeAndLongitude"]){
        [[asyncDataStore objectForKey:@"getLawmakersByLatitudeAndLongitude"] appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSArray *jsonObjects;
    NSError *error;
    NSDictionary *userInfo;
    NSString *postNotificationName;
    
    
    //Parse JSON data for the given connection
    if(connection == asyncCalls[@"getAllLawmakers"]){
        jsonObjects = [NSJSONSerialization JSONObjectWithData:[asyncDataStore objectForKey:@"getAllLawmakers"] options:kNilOptions error:&error];
        userInfo = @{@"allPoliticiansResponse": jsonObjects};
        [asyncDataStore setObject:[[NSMutableData alloc] init] forKey:@"getAllLawmakers"];
        postNotificationName = @"SunlightFactoryDidReceivePoliticianDataNotification";
    }
    else if(connection == asyncCalls[@"getTopDonorsForLawmaker"]){
        jsonObjects = [NSJSONSerialization JSONObjectWithData:[asyncDataStore objectForKey:@"getTopDonorsForLawmaker"] options:kNilOptions error:&error];
        userInfo = @{@"getTopDonorsForLawmakerResponse": jsonObjects};
        [asyncDataStore setObject:[[NSMutableData alloc] init] forKey:@"getTopDonorsForLawmaker"];
        postNotificationName = @"SunlightFactoryDidReceivePoliticianTopDonorForLawmakerNotification";
    }
    else if(connection == asyncCalls[@"getTopDonorIndustriesForLawmaker"]){
        jsonObjects = [NSJSONSerialization JSONObjectWithData:[asyncDataStore objectForKey:@"getTopDonorIndustriesForLawmaker"] options:kNilOptions error:&error];
        userInfo = @{@"getTopDonorIndustriesForLawmaker": jsonObjects};
        [asyncDataStore setObject:[[NSMutableData alloc] init] forKey:@"getTopDonorIndustriesForLawmaker"];
        postNotificationName = @"SunlightFactoryDidReceivePoliticianTopDonorIndustriesForLawmakerNotification";
    }
    else if(connection == asyncCalls[@"getTransparencyID"]){
        jsonObjects = [NSJSONSerialization JSONObjectWithData:[asyncDataStore objectForKey:@"getTransparencyID"] options:kNilOptions error:&error];
        userInfo = @{@"getTransparencyID": jsonObjects};
        [asyncDataStore setObject:[[NSMutableData alloc] init] forKey:@"getTransparencyID"];
        postNotificationName = @"SunlightFactoryDidReceivePoliticianTransparencyIdNotification";
    }
    else if(connection == asyncCalls[@"getTopDonorSectorsForLawmaker"]) {
        jsonObjects = [NSJSONSerialization JSONObjectWithData:[asyncDataStore objectForKey:@"getTopDonorSectorsForLawmaker"] options:kNilOptions error:&error];
        userInfo = @{@"getTopDonorSectorsForLawmaker": jsonObjects};
        [asyncDataStore setObject:[[NSMutableData alloc] init] forKey:@"getTopDonorSectorsForLawmaker"];
        postNotificationName = @"SunlightFactoryDidReceivePoliticianTopDonorSectorsForLawmakerNotification";
    }
    else if(connection == asyncCalls[@"getLawmakersByZipCode"]){
        jsonObjects = [NSJSONSerialization JSONObjectWithData:[asyncDataStore objectForKey:@"getLawmakersByZipCode"] options:kNilOptions error:&error];
        userInfo = @{@"getLawmakersByZipCode": jsonObjects};
        [asyncDataStore setObject:[[NSMutableData alloc] init] forKey:@"getLawmakersByZipCode"];
        postNotificationName = @"SunlightFactoryDidReceivePoliticiansForZipCodeNotification";
    }
    else if(connection == asyncCalls[@"getLawmakersByLatitudeAndLongitude"]){
        jsonObjects = [NSJSONSerialization JSONObjectWithData:[asyncDataStore objectForKey:@"getLawmakersByLatitudeAndLongitude"] options:kNilOptions error:&error];
        [asyncDataStore setObject:[[NSMutableData alloc] init] forKey:@"getLawmakersByLatitudeAndLongitude"];
        userInfo = @{@"getLawmakersByLatitudeAndLongitude": jsonObjects};
        postNotificationName = @"SunlightFactoryDidReceivePoliticiansForLatitudeAndLongitudeNotification";
    }
    else {
        NSLog(@"[SunlightFactory.m] WARNING: Unexpected connection finished loading - Data will not be parsed");
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

-(NSString*)convertSectorCode:(NSString*)code{
    return [sectorCodes objectForKey:code];
}

@end
