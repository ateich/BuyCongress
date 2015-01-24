//
//  ReadabilityFactory.h
//  MyCongress
//
//  Created by HackReactor on 1/23/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReadabilityFactory : NSObject<NSURLConnectionDelegate>{
    NSMutableData *_responseData;
}

-(void)makeReadableArticleFromUrl:(NSString*)url;

@end
