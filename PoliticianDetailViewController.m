//
//  PoliticianDetailViewController.m
//  MyCongress
//
//  Created by HackReactor on 1/6/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "PoliticianDetailViewController.h"

//Need to change this to a scrollview
@interface PoliticianDetailViewController (){
    Politician *politician;
    
    /* LAYOUT CONSTRAINTS */
    int leftMargin;
    int sectionVerticalMargin;
    int subSectionVerticalMargin;
    int topBarHeight;
    
    NSString *topDonorLoaded;
    NSString *topDonorIndustriesLoaded;
    NSString *transparencyIdLoaded;
    
    UILabel *donorsHeader;
    UILabel *donorsByIndustryHeader;
    UILabel *donorsBySectorHeader;
    
    NSLayoutConstraint *donorsByIndustryHeaderTop;
    NSLayoutConstraint *donorsBySectorHeaderTop;
    
    SunlightFactory *sunlightAPI;
}

@end

@implementation PoliticianDetailViewController

@synthesize contactActions;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    contactActions = [[ContactActionsFactory alloc] init];
    [contactActions setViewController:self];
    
    topDonorLoaded = @"SunlightFactoryDidReceivePoliticianTopDonorForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianData:) name:topDonorLoaded object:nil];
    
    topDonorIndustriesLoaded = @"SunlightFactoryDidReceivePoliticianTopDonorIndustriesForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianIndustryData:) name:topDonorIndustriesLoaded object:nil];
    
    transparencyIdLoaded = @"SunlightFactoryDidReceivePoliticianTransparencyIdNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTransparencyId:) name:transparencyIdLoaded object:nil];
    
    //listen for transparency id response
    
    sunlightAPI = [[SunlightFactory alloc] init];
    //get transparency api using bioguide_id
    [sunlightAPI getLawmakerTransparencyIDFromFirstName:politician.firstName andLastName:politician.lastName];
    
    //Autolayout this thingy
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:scrollView];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = [NSString stringWithFormat:@"%@. %@ %@", politician.title, politician.firstName, politician.lastName];
    
    //Layout Constraints
    leftMargin = 25;
    sectionVerticalMargin = 25;
    subSectionVerticalMargin = sectionVerticalMargin/2;
    topBarHeight = 20 + self.navigationController.navigationBar.frame.size.height;
    
    //Sections in View - added to view by creator methods, return objects are only used to position other elements
    UIImageView *photo = [self createPhotoSectionBelow:self.view withImage:nil andLeftMargin:0 aligned:NSTextAlignmentCenter];
    
    NSDictionary *partyStateData = [self createHeaderSectionBelow:photo withName:[NSString stringWithFormat:@"%@ - %@", politician.party, politician.state] andLeftMargin:0 aligned:NSTextAlignmentCenter];
    UILabel *partyStateHeader = [partyStateData objectForKey:@"UILabel"];
    
    NSDictionary *contactHeaderData = [self createHeaderSectionBelow:partyStateHeader withName:@"Contact" andLeftMargin:leftMargin aligned:NSTextAlignmentLeft];
    UILabel *contactHeader = [contactHeaderData objectForKey:@"UILabel"];
    UIButton *contactButtons = [self createContactButtonSection:contactHeader];
    
    NSDictionary *donorsHeaderData = [self createHeaderSectionBelow:contactButtons withName:@"Top Donors" andLeftMargin:leftMargin aligned:NSTextAlignmentLeft];
    donorsHeader = [donorsHeaderData objectForKey:@"UILabel"];
    
    NSDictionary *donorsByIndustryData = [self createHeaderSectionBelow:donorsHeader withName:@"Top Donors by Industry" andLeftMargin:leftMargin aligned:NSTextAlignmentLeft];
    donorsByIndustryHeader = [donorsByIndustryData objectForKey:@"UILabel"];
    donorsByIndustryHeaderTop = [donorsByIndustryData objectForKey:@"topConstraint"];
    
    NSDictionary *donorsBySectorData = [self createHeaderSectionBelow:donorsByIndustryHeader withName:@"Top Donors by Sector" andLeftMargin:leftMargin aligned:NSTextAlignmentLeft];
    donorsBySectorHeader = [donorsBySectorData objectForKey:@"UILabel"];
    donorsBySectorHeaderTop = [donorsBySectorData objectForKey:@"topConstraint"];
}

-(UIImageView*)createPhotoSectionBelow:(id)itemAbove withImage:(UIImage*)image andLeftMargin:(int)leftHandMargin aligned:(NSTextAlignment)alignment {
    UIImageView *photo = [[UIImageView alloc] init];
    [photo setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:photo];
    
    int photoWidth = 75;
    int photoTopPadding = 25;
    
    NSLayoutConstraint *photoTopConstraint = [NSLayoutConstraint constraintWithItem:photo attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:topBarHeight + photoTopPadding];
    
    NSLayoutConstraint *photoCenterConstraint = [NSLayoutConstraint constraintWithItem:photo attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    
    NSLayoutConstraint *photoHeightConstraint = [NSLayoutConstraint constraintWithItem:photo attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:photoWidth];
    
    NSLayoutConstraint *photoWidthConstraint = [NSLayoutConstraint constraintWithItem:photo attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:photoWidth];
    
    [self.view addConstraint:photoTopConstraint];
    [self.view addConstraint:photoCenterConstraint];
    [self.view addConstraint:photoHeightConstraint];
    [self.view addConstraint:photoWidthConstraint];
    
    //TO DO: If there isn't an image for the Congressman, show an alternate image
    if(!image){
        [photo setBackgroundColor:[UIColor blackColor]];
    }

    return photo;
}

-(NSDictionary *)createHeaderSectionBelow:(id)itemAbove withName:(NSString*)title andLeftMargin:(int)leftHandMargin aligned:(NSTextAlignment)alignment {
    UILabel *header = [[UILabel alloc] init];
    [header setTextAlignment:alignment];
    [self.view addSubview:header];
    int headerHeight = 25;
    header.text = title;
    
    [header setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSLayoutConstraint *headerTopConstraint = [NSLayoutConstraint constraintWithItem:header attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:itemAbove attribute:NSLayoutAttributeBottom multiplier:1.0 constant:sectionVerticalMargin];
    
    NSLayoutConstraint *headerLeftConstraint = [NSLayoutConstraint constraintWithItem:header attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:leftHandMargin];
    
    NSLayoutConstraint *headerWidthConstraint = [NSLayoutConstraint constraintWithItem:header attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    
    NSLayoutConstraint *headerHeightConstraint = [NSLayoutConstraint constraintWithItem:header attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:headerHeight];
    
    [self.view addConstraint:headerTopConstraint];
    [self.view addConstraint:headerLeftConstraint];
    [self.view addConstraint:headerWidthConstraint];
    [self.view addConstraint:headerHeightConstraint];
    
    return [NSDictionary dictionaryWithObjectsAndKeys: header, @"UILabel", headerTopConstraint, @"topConstraint", nil];
}

/** 
 * Creates contact buttons below itemAbove and returns an id that can be used to position elements after this section
 */
-(UIButton *)createContactButtonSection:(id)itemAbove {
    //Check which contact information the Politician has
    NSMutableArray *contactMethods = [[NSMutableArray alloc] init];
    
    if(politician.twitter){
//        [contactMethods addObject:[NSArray arrayWithObjects:@"twitter", @"TEST", nil]];
    }
    if(politician.youtubeID){
//        [contactMethods addObject:[NSArray arrayWithObjects:@"youtube", @"TEST", nil]];
    }
    if(politician.phone){
        [contactMethods addObject:[NSArray arrayWithObjects:@"phone", @"makePhoneCall", nil]];
    }
    if(politician.email){
        [contactMethods addObject:[NSArray arrayWithObjects:@"email", @"sendEmail", nil]];
    }
    if(politician.website){
//        [contactMethods addObject:[NSArray arrayWithObjects:@"website", @"loadWebsite", nil]];
    }
    
    
    id leftSide;
    int buttonSize = 30;
    
    //Create a contact button for each available contact method
    for(int i=0; i<contactMethods.count; i++){
        UIButton *contactButton = [[UIButton alloc] init];
        [self.view addSubview:contactButton];
        
        //set button selector with variable?
        SEL aSelector = NSSelectorFromString([[contactMethods objectAtIndex:i] objectAtIndex:1]);
        [contactButton addTarget:self action:aSelector forControlEvents:UIControlEventTouchDown];
        
        [contactButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [contactButton setBackgroundImage:[UIImage imageNamed:[[contactMethods objectAtIndex:i] objectAtIndex:0]] forState:UIControlStateNormal];
        
        //Make sure the first button left aligns to the main view
        // and have the other buttons left align to the button to their left
        NSLayoutConstraint *contactLeftConstraint;
        if(!leftSide){
            leftSide = self.view;
            
            contactLeftConstraint = [NSLayoutConstraint constraintWithItem:contactButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:leftSide attribute:NSLayoutAttributeLeading multiplier:1.0 constant:leftMargin];
        } else {
            contactLeftConstraint = [NSLayoutConstraint constraintWithItem:contactButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:leftSide attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:leftMargin];
        }
        
        //Other button constraints
        NSLayoutConstraint *contactTopConstraint = [NSLayoutConstraint constraintWithItem:contactButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:itemAbove attribute:NSLayoutAttributeBottom multiplier:1.0 constant:subSectionVerticalMargin];
        
        NSLayoutConstraint *contactWidthConstraint = [NSLayoutConstraint constraintWithItem:contactButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:buttonSize];
        
        NSLayoutConstraint *contactHeightConstraint = [NSLayoutConstraint constraintWithItem:contactButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:buttonSize];
        
        [self.view addConstraint:contactTopConstraint];
        [self.view addConstraint:contactLeftConstraint];
        [self.view addConstraint:contactWidthConstraint];
        [self.view addConstraint:contactHeightConstraint];
        
        //Save this button to be used in left positioning the next button
        leftSide = contactButton;
    }
    
    //return the last button so the next section can use it to position itself
    return leftSide;
}

- (void)didReceivePoliticianData:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSArray *donors = [userInfo objectForKey:@"getTopDonorsForLawmakerResponse"];
    [self formatDonorsFromArray:donors];
}

-(void)didReceivePoliticianIndustryData:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSArray *donorIndustries = [userInfo objectForKey:@"getTopDonorIndustriesForLawmaker"];
    NSLog(@"%@", [donorIndustries description]);
//    [self formatDonorsFromArray:donorIndustries];
}

-(void)didReceiveTransparencyId:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSArray *politicians = [userInfo objectForKey:@"getTransparencyID"];
    NSString *transparencyID = [[politicians objectAtIndex:0] objectForKey:@"id"];
    
    //get transparency data using ID
    
    [sunlightAPI getTopDonorsForLawmaker:transparencyID];
    [sunlightAPI getTopDonorIndustriesForLawmaker:transparencyID];
}

-(void)formatDonorsFromArray:(NSArray*)donors {
    UILabel *top = donorsHeader;
    
    for(int i=0; i<donors.count; i++){
        NSDictionary *donor = [donors objectAtIndex:i];
        NSString *totalAmount = [donor objectForKey:@"total_amount"];
        NSString *donorName = [donor objectForKey:@"name"];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *total = [numberFormatter numberFromString:totalAmount];
        
        [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        totalAmount = [numberFormatter stringFromNumber:total];
        
        NSString *labelText = [NSString stringWithFormat:@"%@ - %@", donorName, totalAmount];
        top = [[self createHeaderSectionBelow:top withName:labelText andLeftMargin:leftMargin aligned:NSTextAlignmentLeft] objectForKey:@"UILabel"];
    }
    
    [self.view removeConstraint:donorsByIndustryHeaderTop];
    donorsByIndustryHeaderTop = [NSLayoutConstraint constraintWithItem:donorsByIndustryHeader attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:top attribute:NSLayoutAttributeBottom multiplier:1.0 constant:sectionVerticalMargin];
    [self.view addConstraint:donorsByIndustryHeaderTop];
}

#pragma mark - Contact Delegate Methods
-(void)TEST{
    NSLog(@"TEST");
}

-(void)sendEmail {
    [contactActions composeEmail];
}

-(void)makePhoneCall {
    [contactActions makePhoneCall:politician.phone];
}

-(void)loadWebsite {
    [contactActions loadWebsite:politician.website];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)setPolitician:(Politician *)newPolitician{
    politician = newPolitician;
}

@end
