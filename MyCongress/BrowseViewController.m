//
//  BrowseViewController.m
//  MyCongress
//
//  Created by Andrew Teich on 12/11/14.
//  Copyright (c) 2014 Andrew Teich. All rights reserved.
//

#import "BrowseViewController.h"
#import "SunlightFactory.h"
#import "PoliticianTableViewController.h"
#import "Politician.h"
#import "AttributionViewController.h"
#import "ColorScheme.h"

@interface BrowseViewController (){
    NSString *politicianDataChanged;
    PoliticianTableViewController *tableVC;
    AttributionViewController *attributions;
    bool gatheredData;
    UIActivityIndicatorView *loading;
}

@end

@implementation BrowseViewController

- (void) dealloc {
    //Stop listening for changes to Politician Data
    NSLog(@"[BrowseViewController.m] TEST: Stop Listening for Politician Data Changes");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:politicianDataChanged object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    attributions = [[AttributionViewController alloc] init];
    
    self.view.backgroundColor = [ColorScheme backgroundColor];
    
    //Listen for changes to Politician Data
    politicianDataChanged = @"SunlightFactoryDidReceiveGetAllLawmakersNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianData:) name:politicianDataChanged object:nil];
    
    //Get all politicians asynchronously
    SunlightFactory *sunlight = [[SunlightFactory alloc] init];
    [sunlight getAllLawmakers];
    
    //Add table to display all politicians to the view
    tableVC = [[PoliticianTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [tableVC useFadeInAnimation:YES];
    [self addChildViewController:tableVC];
    [tableVC didMoveToParentViewController:self];
    
    CGRect tableFrame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
    tableVC.view.frame = tableFrame;
    [self.view addSubview:tableVC.view];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Browse" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //Loading indicator
    loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loading.translatesAutoresizingMaskIntoConstraints = NO;
    loading.color = [ColorScheme headerColor];
    loading.hidesWhenStopped = YES;
    [self.view addSubview:loading];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loading attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loading attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [loading startAnimating];
}

-(void)viewDidAppear:(BOOL)animated{
    if(!gatheredData){
        [loading startAnimating];
        SunlightFactory *sunlight = [[SunlightFactory alloc] init];
        [sunlight getAllLawmakers];
    }
}

- (void)didReceivePoliticianData:(NSNotification*)notification {
    gatheredData = true;
    NSDictionary *userInfo = [notification userInfo];
    NSArray *politicianData = userInfo[@"results"][@"results"];
    [tableVC updateTableViewWithNewData:[tableVC createPoliticiansFromDataArray:politicianData]];
    [loading stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"[BrowseViewController.m] TEST: DID RECEIVE MEMORY WARNING - Testing Event Listening");
}

-(IBAction)showAttributions:(id)sender{
    [self presentViewController:attributions animated:YES completion:nil];
}

@end
