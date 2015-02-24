//
//  ContactActionsFactory.m
//  MyCongress
//
//  Created by HackReactor on 1/8/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "ContactActionsFactory.h"

@implementation ContactActionsFactory
@synthesize currentViewController;

-(id)init{
    self = [super init];
    return self;
}

-(void)setViewController:(UIViewController *)viewController {
    currentViewController = viewController;
}

-(void)composeEmail:(NSString*)emailAddress {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    
    controller.mailComposeDelegate = self;
    [controller setToRecipients:[NSArray arrayWithObject:emailAddress]];
    [controller setSubject:@""];
    [controller setMessageBody:@"" isHTML:NO];
    if (controller){
        
        [controller.navigationBar setTintColor:[UIColor whiteColor]];
        [controller.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        
        [currentViewController presentViewController:controller animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            
        }];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (result == MFMailComposeResultSent) {
        NSLog(@"Sent Email");
    }
    
    [currentViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)makePhoneCall:(NSString*)phoneNumber {
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", cleanedString]];
    [[UIApplication sharedApplication] openURL:telURL];
}

//To Do: Re-create with WKWebView
-(void)loadWebsite:(NSString*)url {
    UIViewController *webviewController = [[UIViewController alloc] init];
    UIWebView *webview=[[UIWebView alloc] initWithFrame:currentViewController.view.frame];
    [webviewController setView:webview];
    
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [webview loadRequest:nsrequest];
    [currentViewController presentViewController:webviewController animated:YES completion:nil];
}

//Compose Tweet



@end
