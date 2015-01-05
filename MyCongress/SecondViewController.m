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

@interface SecondViewController (){
    NSString *politicianDataChanged;
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
    
    //TEST OF SUNLIGHT API CALLS
    SunlightFactory *sunlight = [[SunlightFactory alloc] init];
    NSArray *lawmakers = [sunlight getAllLawmakers];
    NSLog(@"Lawmakers: %@", lawmakers);
    
    //Add table of all politicians to the view
    TableViewController *tableVC = [[TableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self addChildViewController:tableVC];
    [tableVC didMoveToParentViewController:self];
    tableVC.view.frame = self.view.frame;
    [self.view addSubview:tableVC.view];
    
    
//    tableVC.politicians = returned data from JSON emitted notification
    
    
    
    //Add Loading Pop-Up with Spinner
    //Wait for data to load
    //Remove Pop-up and Spinner
    //Show Data
    
    //Need to breakout tableview and tableview cell into new classes
    
}

- (void)didReceivePoliticianData:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSDictionary *politicianData = [[userInfo objectForKey:@"allPoliticiansResponse"] objectForKey:@"results"];
    
    //Use the politicianData to create Politicians and display them in the tableView
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"[SecondViewController.m] TEST: DID RECEIVE MEMORY WARNING - Testing Event Listening");
}

@end
