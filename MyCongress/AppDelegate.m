//
//  AppDelegate.m
//  MyCongress
//
//  Created by Andrew Teich on 12/11/14.
//  Copyright (c) 2014 Andrew Teich. All rights reserved.
//

#import "AppDelegate.h"
#import "ColorScheme.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Set tab and navigation bar color
    
    [UITabBar appearance].translucent = NO;
    [UITabBar appearance].barTintColor = [ColorScheme navBarColor];
    
    [UINavigationBar appearance].translucent = NO;
    [UINavigationBar appearance].barTintColor = [ColorScheme navBarColor];
    
    // set the text color for selected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    // set the text color for unselected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    // set the selected icon color
    [UITabBar appearance].tintColor = [UIColor whiteColor];
    
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    
    for(UITabBarItem *tab in tabBar.items){
        tab.image = [tab.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tab.selectedImage = [tab.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        if([tab.title isEqualToString:@"Influence Explorer"]){
            tab.image = [UIImage imageNamed:@"CongressIcon"];
        }
    }
    
    //set nav bar back button and text color
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
