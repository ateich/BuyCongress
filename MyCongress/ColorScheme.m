//
//  ColorScheme.m
//  MyCongress
//
//  Created by HackReactor on 2/20/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "ColorScheme.h"

@implementation ColorScheme

+ (UIColor *)headerColor{
    return [self textColor];
}

+ (UIColor *)textColor{
    return [UIColor colorWithRed:17.0/255.0 green:34.0/255.0 blue:51.0/255.0 alpha:1.0];
}

+ (UIColor *)subTextColor{
    return [UIColor colorWithRed:102.0/255.0 green:204.0/255.0 blue:153.0/255.0 alpha:1.0];
}

+ (UIColor *)backgroundColor{
    return [UIColor colorWithRed:240.0/255.0 green:241.0/255.0 blue:245.0/255.0 alpha:1.0];
}

+ (UIColor *)navBarColor{
    return [UIColor colorWithRed:68.0/255.0 green:187.0/255.0 blue:255.0/255.0 alpha:1.0];
}

+ (UIColor *)placeholderImageColor{
    return [self headerColor];
}

+ (UIColor *)cardColor{
    return [UIColor whiteColor];
}



@end
