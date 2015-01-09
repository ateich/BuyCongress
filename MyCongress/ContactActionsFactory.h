//
//  ContactActionsFactory.h
//  MyCongress
//
//  Created by HackReactor on 1/8/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface ContactActionsFactory : NSObject<MFMailComposeViewControllerDelegate>{
    UIViewController *currentViewController;
}

-(void)composeEmail:(UIViewController*)viewController;
@property (nonatomic, strong) UIViewController *currentViewController;

@end
