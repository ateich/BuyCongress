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
#import "AttributionViewController.h"
#import "ColorScheme.h"

@interface SecondViewController (){
    NSString *politicianDataChanged;
    TableViewController *tableVC;
    AttributionViewController *attributions;
    bool gatheredData;
    UIActivityIndicatorView *loading;
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
    
    attributions = [[AttributionViewController alloc] init];
    
    [self.view setBackgroundColor:[ColorScheme backgroundColor]];
    
    //Listen for changes to Politician Data
    politicianDataChanged = @"SunlightFactoryDidReceiveGetAllLawmakersNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianData:) name:politicianDataChanged object:nil];
    
    //Get all politicians asynchronously
    SunlightFactory *sunlight = [[SunlightFactory alloc] init];
    [sunlight getAllLawmakers];
    
    //Add table to display all politicians to the view
    tableVC = [[TableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self addChildViewController:tableVC];
    [tableVC didMoveToParentViewController:self];
    
    CGRect tableFrame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
    tableVC.view.frame = tableFrame;
    [self.view addSubview:tableVC.view];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Browse" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //Loading indicator
    loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loading setColor:[ColorScheme headerColor]];
    [loading setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:loading];
    [loading setHidesWhenStopped:YES];
    
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
    NSArray *politicianData = [[userInfo objectForKey:@"results"] objectForKey:@"results"];
    [tableVC updateTableViewWithNewData:[tableVC createPoliticiansFromDataArray:politicianData]];
    [loading stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"[SecondViewController.m] TEST: DID RECEIVE MEMORY WARNING - Testing Event Listening");
}

-(IBAction)showAttributions:(id)sender{
    [self presentViewController:attributions animated:YES completion:nil];
}

@end
