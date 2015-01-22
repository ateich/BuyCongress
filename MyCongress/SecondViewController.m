//
//  SecondViewController.m
//  MyCongress
//
//  Created by Andrew Teich on 12/11/14.
//  Copyright (c) 2014 Andrew Teich. All rights reserved.
//

#import "SecondViewController.h"
#import "SunlightFactory.h"
#import "TableViewController.h"
#import "Politician.h"

@interface SecondViewController (){
    NSString *politicianDataChanged;
    TableViewController *tableVC;
}

@end

@implementation SecondViewController

- (void) dealloc {
    //Stop listening for changes to Politician Data
    NSLog(@"[SecondViewController.m] TEST: Stop Listening for Politician Data Changes");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:politicianDataChanged object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Listen for changes to Politician Data
    politicianDataChanged = @"SunlightFactoryDidReceivePoliticianDataNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianData:) name:politicianDataChanged object:nil];
    
    //Get all politicians asynchronously
    SunlightFactory *sunlight = [[SunlightFactory alloc] init];
    [sunlight getAllLawmakers];
    
    //Add table to display all politicians to the view
    tableVC = [[TableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self addChildViewController:tableVC];
    [tableVC didMoveToParentViewController:self];
    
    int topBarHeight = 20 + self.navigationController.navigationBar.frame.size.height;
    CGRect tableFrame = CGRectMake(self.view.frame.origin.x, topBarHeight, self.view.frame.size.width, self.view.frame.size.height-topBarHeight-self.tabBarController.tabBar.frame.size.height);
    tableVC.view.frame = tableFrame;
    [self.view addSubview:tableVC.view];
    
    //TO DO: Show user something so that they know the data is loading
}

- (void)didReceivePoliticianData:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSArray *politicianData = [[userInfo objectForKey:@"allPoliticiansResponse"] objectForKey:@"results"];
    [tableVC updateTableViewWithNewData:[tableVC createPoliticiansFromDataArray:politicianData]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"[SecondViewController.m] TEST: DID RECEIVE MEMORY WARNING - Testing Event Listening");
}

@end
