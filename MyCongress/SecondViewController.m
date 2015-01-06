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
    int topBarHeight = 20;
    CGRect tableFrame = CGRectMake(self.view.frame.origin.x, topBarHeight, self.view.frame.size.width, self.view.frame.size.height-topBarHeight);
    tableVC.view.frame = tableFrame;
    [self.view addSubview:tableVC.view];
    
    //TO DO: Show user something so that they know the data is loading
}

- (void)didReceivePoliticianData:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSArray *politicianData = [[userInfo objectForKey:@"allPoliticiansResponse"] objectForKey:@"results"];
    [tableVC updateTableViewWithNewData:[self createPoliticiansFromDataArray:politicianData]];
}

-(NSMutableArray *)createPoliticiansFromDataArray:(NSArray *)politicianData{
    NSMutableArray *politiciansFromData = [[NSMutableArray alloc] init];
    
    for(int i=0; i<politicianData.count; i++){
        NSDictionary *thisPoliticiansData = [politicianData objectAtIndex:i];
        Politician *aPolitician = [[Politician alloc] init];
        
        [aPolitician setFirstName: [thisPoliticiansData objectForKey:@"first_name"]];
        [aPolitician setLastName: [thisPoliticiansData objectForKey:@"last_name"]];
        [aPolitician setGender: [thisPoliticiansData objectForKey:@"gender"]]; //May have an issue, check this
        
        [aPolitician setEmail: [thisPoliticiansData objectForKey:@"oc_email"]];
        [aPolitician setPhone: [thisPoliticiansData objectForKey:@"phone"]];
        [aPolitician setEmail: [thisPoliticiansData objectForKey:@"oc_email"]];
        [aPolitician setTwitter: [thisPoliticiansData objectForKey:@"twitter_id"]];
        [aPolitician setYoutubeID: [thisPoliticiansData objectForKey:@"youtube_id"]];
        
        NSString *party = [thisPoliticiansData objectForKey:@"party"];
        if([party  isEqual: @"D"]){
            party = @"Democrat";
        } else {
            party = @"Republican";
        }
        
        [aPolitician setParty: party];
        [aPolitician setTitle: [thisPoliticiansData objectForKey:@"title"]];
        [aPolitician setState: [thisPoliticiansData objectForKey:@"state_name"]];
        
        [politiciansFromData addObject:aPolitician];
    }
    return politiciansFromData;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"[SecondViewController.m] TEST: DID RECEIVE MEMORY WARNING - Testing Event Listening");
}

@end
