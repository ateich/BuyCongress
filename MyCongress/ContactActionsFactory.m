//
//  ContactActionsFactory.m
//  MyCongress
//
//  Created by HackReactor on 1/8/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "ContactActionsFactory.h"

@implementation ContactActionsFactory{
}
@synthesize currentViewController;

-(id)init{
    self = [super init];
    return self;
}

-(void)composeEmail:(UIViewController*)viewController{
    currentViewController = viewController;
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"My Subject"];
    [controller setMessageBody:@"Hello there." isHTML:NO];
    if (controller){
        [currentViewController presentViewController:controller animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"Sent Email");
    }
    
    [currentViewController dismissViewControllerAnimated:YES completion:nil];
}



@end
