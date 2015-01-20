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
//    int leftMargin;
    int sectionVerticalMargin;
    int subSectionVerticalMargin;
    int topBarHeight;
    
    UIScrollView *scrollView;
    UIView *contentView;
    
    NSString *topDonorLoaded;
    NSString *topDonorIndustriesLoaded;
    NSString *transparencyIdLoaded;
    NSString *topDonorSectorsLoaded;
    
//    UILabel *donorsHeader;
//    UILabel *donorsByIndustryHeader;
//    UILabel *donorsBySectorHeader;
    
    UIView *contactSection;
    UIView *individualDonorsSection;
    UIView *industryDonorsSection;
    UIView *sectorDonorsSection;
    
    NSLayoutConstraint *donorsByIndustryHeaderTop;
    NSLayoutConstraint *donorsBySectorHeaderTop;
    
    SunlightFactory *sunlightAPI;
}

@end

@implementation PoliticianDetailViewController

@synthesize contactActions;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = [NSString stringWithFormat:@"%@. %@ %@", politician.title, politician.firstName, politician.lastName];
    
    scrollView = [[UIScrollView alloc] init];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:scrollView];
    [scrollView setBackgroundColor:[UIColor greenColor]];
    
    contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor redColor]];
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [scrollView addSubview:contentView];
    
    //Politician's Photo
    UIImageView *photo = [[UIImageView alloc] init];
    [photo setBackgroundColor:[UIColor blackColor]];
    [photo setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:photo];
    
    /** Break out into their own views */
    //Each section contains a header and subheaders generated from an array of data
    
    //Contact Section
    contactSection =[[UIView alloc] init];
    [contactSection setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:contactSection];
    
    //Individual Donors Section
    individualDonorsSection =[[UIView alloc] init];
    [individualDonorsSection setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:individualDonorsSection];
    [individualDonorsSection setBackgroundColor:[UIColor orangeColor]];
    
    //Industry Donors Section
    industryDonorsSection =[[UIView alloc] init];
    [industryDonorsSection setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:industryDonorsSection];
    
    //Sector Donors Section
    sectorDonorsSection =[[UIView alloc] init];
    [sectorDonorsSection setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:sectorDonorsSection];
    
    //AUTO LAYOUT (VFL)
    NSDictionary *views = NSDictionaryOfVariableBindings(scrollView, contentView);
    
    //Scroll View Layout
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrollView]-0-|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView(==scrollView)]|" options:0 metrics:nil views:views]];
    //    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:contentView
    //                                                           attribute:NSLayoutAttributeWidth
    //                                                           relatedBy:NSLayoutRelationEqual
    //                                                              toItem:scrollView
    //                                                           attribute:NSLayoutAttributeWidth
    //                                                          multiplier:1.0f
    //                                                            constant:0.0f]];
    
    //Entire page layout, vertically
    views = NSDictionaryOfVariableBindings(contentView, photo, contactSection, individualDonorsSection, industryDonorsSection, sectorDonorsSection);
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[photo(75)]-25-[contactSection]-25-[individualDonorsSection]-25-[industryDonorsSection]-25-[sectorDonorsSection]|" options:0 metrics:nil views:views]];
    
    //Photo layout
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:photo attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:75]];
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:photo attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[individualDonorsSection]-0-|" options:0 metrics:nil views:views]];
    
    
    [self createContactSection];
    

    
    
    //Enable sharing actions
    contactActions = [[ContactActionsFactory alloc] init];
    [contactActions setViewController:self];
    
    //Listen for asynchronous callbacks of politician donor data
    topDonorLoaded = @"SunlightFactoryDidReceivePoliticianTopDonorForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianData:) name:topDonorLoaded object:nil];
    
    topDonorIndustriesLoaded = @"SunlightFactoryDidReceivePoliticianTopDonorIndustriesForLawmakerNotification";
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianIndustryData:) name:topDonorIndustriesLoaded object:nil];
    
    transparencyIdLoaded = @"SunlightFactoryDidReceivePoliticianTransparencyIdNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTransparencyId:) name:transparencyIdLoaded object:nil];
    
    topDonorSectorsLoaded = @"SunlightFactoryDidReceivePoliticianTopDonorSectorsForLawmakerNotification";
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianDataSectorData:) name:topDonorSectorsLoaded object:nil];
    
    
    //get transparency id to use in receiving politician donor data
    sunlightAPI = [[SunlightFactory alloc] init];
    [sunlightAPI getLawmakerTransparencyIDFromFirstName:politician.firstName andLastName:politician.lastName];

    
    
    //Layout Constraints
//    leftMargin = 25;
//    sectionVerticalMargin = 25;
//    subSectionVerticalMargin = sectionVerticalMargin/2;
//    topBarHeight = 20 + self.navigationController.navigationBar.frame.size.height;
//    
//    //Sections in View - added to view by creator methods, return objects are only used to position other elements
//    UIImageView *photo = [self createPhotoSectionOn:contentView below:contentView withImage:nil andLeftMargin:0 aligned:NSTextAlignmentCenter];
//    
//    NSDictionary *partyStateData = [self createHeaderSectionOn:contentView below:photo withName:[NSString stringWithFormat:@"%@ - %@", politician.party, politician.state] andLeftMargin:0 aligned:NSTextAlignmentCenter];
//    UILabel *partyStateHeader = [partyStateData objectForKey:@"UILabel"];
//    
//    NSDictionary *contactHeaderData = [self createHeaderSectionOn:contentView below:partyStateHeader withName:@"Contact" andLeftMargin:leftMargin aligned:NSTextAlignmentLeft];
//    UILabel *contactHeader = [contactHeaderData objectForKey:@"UILabel"];
//    UIButton *contactButtons = [self createContactButtonSectionOn:contentView below:contactHeader];
//    
//    NSDictionary *donorsHeaderData = [self createHeaderSectionOn:contentView below:contactButtons withName:@"Top Individual Donors" andLeftMargin:leftMargin aligned:NSTextAlignmentLeft];
//    donorsHeader = [donorsHeaderData objectForKey:@"UILabel"];
//    
//    NSDictionary *donorsByIndustryData = [self createHeaderSectionOn:contentView below:donorsHeader withName:@"Top Donors by Industry" andLeftMargin:leftMargin aligned:NSTextAlignmentLeft];
//    donorsByIndustryHeader = [donorsByIndustryData objectForKey:@"UILabel"];
//    donorsByIndustryHeaderTop = [donorsByIndustryData objectForKey:@"topConstraint"];
//    
//    NSDictionary *donorsBySectorData = [self createHeaderSectionOn:contentView below:donorsByIndustryHeader withName:@"Top Donors by Sector" andLeftMargin:leftMargin aligned:NSTextAlignmentLeft];
//    donorsBySectorHeader = [donorsBySectorData objectForKey:@"UILabel"];
//    donorsBySectorHeaderTop = [donorsBySectorData objectForKey:@"topConstraint"];
//    
//    [contentView layoutIfNeeded];
}

-(void)createContactSection{
    [contactSection setBackgroundColor:[UIColor yellowColor]];
    
    NSNumber *leftMargin = [[NSNumber alloc] initWithInt:25];
    int topMargin = 10;
    NSDictionary *metrics = @{@"leftMargin":leftMargin};
    
    //create section header
    UILabel *header = [[UILabel alloc] init];
    [header setTranslatesAutoresizingMaskIntoConstraints:NO];
    header.text = @"Contact";
    [contactSection addSubview:header];
    
    [contactSection addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[header]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(header)]];
    [contactSection addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[header]-0-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(header)]];
    
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
        [contactSection addSubview:contactButton];
        
        //set button selector with variable?
        SEL aSelector = NSSelectorFromString([[contactMethods objectAtIndex:i] objectAtIndex:1]);
        [contactButton addTarget:self action:aSelector forControlEvents:UIControlEventTouchDown];
        
        [contactButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [contactButton setBackgroundImage:[UIImage imageNamed:[[contactMethods objectAtIndex:i] objectAtIndex:0]] forState:UIControlStateNormal];
        
        //Make sure the first button left aligns to the main view
        // and have the other buttons left align to the button to their left
        NSLayoutConstraint *contactLeftConstraint;
        if(!leftSide){
            leftSide = contactSection;
            
            contactLeftConstraint = [NSLayoutConstraint constraintWithItem:contactButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:leftSide attribute:NSLayoutAttributeLeading multiplier:1.0 constant:[leftMargin doubleValue]];
        } else {
            contactLeftConstraint = [NSLayoutConstraint constraintWithItem:contactButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:leftSide attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:[leftMargin doubleValue]];
        }
        
        //Other button constraints
        NSLayoutConstraint *contactTopConstraint = [NSLayoutConstraint constraintWithItem:contactButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:header attribute:NSLayoutAttributeBottom multiplier:1.0 constant:topMargin];
        
        NSLayoutConstraint *contactWidthConstraint = [NSLayoutConstraint constraintWithItem:contactButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:buttonSize];
        
        NSLayoutConstraint *contactHeightConstraint = [NSLayoutConstraint constraintWithItem:contactButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:buttonSize];
        
        [contactSection addConstraint:contactTopConstraint];
        [contactSection addConstraint:contactLeftConstraint];
        [contactSection addConstraint:contactWidthConstraint];
        [contactSection addConstraint:contactHeightConstraint];
        
        //Save this button to be used in left positioning the next button
        leftSide = contactButton;
    }
}

-(void)createIndividualDonorSection:(NSArray*)donors{
    UILabel *header = [[UILabel alloc] init];
    header.text = @"Top Individual Donors";
    UILabel *top = [[UILabel alloc] init];
    [top setTranslatesAutoresizingMaskIntoConstraints:NO];
    [individualDonorsSection addSubview:top];
    top.text = @"Top Individual Donors";
    
    NSNumber *leftMargin = [NSNumber numberWithInt:25];
    NSDictionary *metrics = @{@"leftMargin":leftMargin};
    
    [individualDonorsSection addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[top]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(top)]];
    [individualDonorsSection addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[top]-0-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(top)]];
    
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
        UILabel *label = [[UILabel alloc] init];
        [individualDonorsSection addSubview:label];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        label.text = labelText;
        
//        top = [[self createHeaderSectionOn:view below:top withName:labelText andLeftMargin:leftMargin aligned:NSTextAlignmentLeft] objectForKey:@"UILabel"];
        
//        NSDictionary *views;
        
//        if(!top){
//            views = NSDictionaryOfVariableBindings(label);
//            [individualDonorsSection addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[label]|" options:0 metrics:nil views:views]];
//        } else {
//            views = NSDictionaryOfVariableBindings(top, label);
//            [individualDonorsSection addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[top]-0-[label]|" options:0 metrics:nil views:views]];
//        }
//        [individualDonorsSection addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[label]-0-|" options:0 metrics:nil views:views]];
        
        NSLayoutConstraint *topConstraint;
        if(!top){
            topConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:individualDonorsSection attribute:NSLayoutAttributeBottom multiplier:1.0 constant:15];
        } else {
            topConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:top attribute:NSLayoutAttributeBottom multiplier:1.0 constant:15];
        }
        
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:individualDonorsSection attribute:NSLayoutAttributeLeading multiplier:1.0 constant:[leftMargin doubleValue]];
        
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:individualDonorsSection attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
        
        [individualDonorsSection addConstraints:[NSArray arrayWithObjects:topConstraint, leftConstraint, rightConstraint, nil]];
        
        top = label;
    }
    [individualDonorsSection setBackgroundColor:[UIColor purpleColor]];
    [individualDonorsSection updateConstraints];
    [[individualDonorsSection superview] updateConstraints];
//    [contentView updateConstraints];
    //    [view removeConstraint:donorsByIndustryHeaderTop];
    //    donorsByIndustryHeaderTop = [NSLayoutConstraint constraintWithItem:donorsByIndustryHeader attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:top attribute:NSLayoutAttributeBottom multiplier:1.0 constant:sectionVerticalMargin];
    //    [view addConstraint:donorsByIndustryHeaderTop];
}

- (void)didReceivePoliticianData:(NSNotification*)notification {
    NSLog(@"didReceivePoliticianData");
    NSDictionary *userInfo = [notification userInfo];
    NSArray *donors = [userInfo objectForKey:@"getTopDonorsForLawmakerResponse"];
//    [self formatDonorsFromArray:donors onView:contentView];
    [self createIndividualDonorSection:donors];
}

-(void)didReceivePoliticianIndustryData:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSArray *donorIndustries = [userInfo objectForKey:@"getTopDonorIndustriesForLawmaker"];
//    NSLog(@"%@", [donorIndustries description]);
//    [self formatDonorsFromArray:donorIndustries];
}

-(void)didReceivePoliticianDataSectorData:(NSNotification*)notification{
    NSLog(@"didReceivePoliticianDataSectorData");
    NSDictionary *userInfo = [notification userInfo];
    NSArray *donorSectors = [userInfo objectForKey:@"getTopDonorSectorsForLawmaker"];
    NSLog(@"%@", [donorSectors description]);
    //    [self formatDonorsFromArray:donorSectors];
}

-(void)didReceiveTransparencyId:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSArray *politicians = [userInfo objectForKey:@"getTransparencyID"];
    
    NSLog(@"didReceiveTransparencyId");
    
    if(politicians.count > 0){
        NSString *transparencyID = [[politicians objectAtIndex:0] objectForKey:@"id"];
        
        [sunlightAPI getTopDonorsForLawmaker:transparencyID];
        [sunlightAPI getTopDonorIndustriesForLawmaker:transparencyID];
        [sunlightAPI getTopDonorSectorsForLawmaker:transparencyID];
    } else {
        NSLog(@"[PoliticianDetailViewController.m] WARNING: Politician not found while checking for transparency id - Donation data will not be shown");
    }
}

-(void)formatDonorsFromArray:(NSArray*)donors onView:(UIView*)view {
//    UILabel *top = donorsHeader;
//    
//    for(int i=0; i<donors.count; i++){
//        NSDictionary *donor = [donors objectAtIndex:i];
//        NSString *totalAmount = [donor objectForKey:@"total_amount"];
//        NSString *donorName = [donor objectForKey:@"name"];
//        
//        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//        NSNumber *total = [numberFormatter numberFromString:totalAmount];
//        
//        [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
//        totalAmount = [numberFormatter stringFromNumber:total];
//        
//        NSString *labelText = [NSString stringWithFormat:@"%@ - %@", donorName, totalAmount];
//        top = [[self createHeaderSectionOn:view below:top withName:labelText andLeftMargin:leftMargin aligned:NSTextAlignmentLeft] objectForKey:@"UILabel"];
//    }
    
//    [view removeConstraint:donorsByIndustryHeaderTop];
//    donorsByIndustryHeaderTop = [NSLayoutConstraint constraintWithItem:donorsByIndustryHeader attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:top attribute:NSLayoutAttributeBottom multiplier:1.0 constant:sectionVerticalMargin];
//    [view addConstraint:donorsByIndustryHeaderTop];
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
