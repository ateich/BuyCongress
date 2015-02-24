//
//  PoliticianDetailViewController.m
//  MyCongress
//
//  Created by HackReactor on 1/6/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "PoliticianDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorScheme.h"

//Need to change this to a scrollview
@interface PoliticianDetailViewController (){
    Politician *politician;
    
    /* LAYOUT CONSTRAINTS */
    int sectionVerticalMargin;
    int subSectionVerticalMargin;
    int topBarHeight;
    
    UIScrollView *scrollView;
    UIView *contentView;
    
    NSString *topDonorLoaded;
    NSString *topDonorIndustriesLoaded;
    NSString *transparencyIdLoaded;
    NSString *topDonorSectorsLoaded;
    
    UIView *contactSection;
    UIView *individualDonorsSection;
    UIView *industryDonorsSection;
    UIView *sectorDonorsSection;
    
    NSLayoutConstraint *donorsByIndustryHeaderTop;
    NSLayoutConstraint *donorsBySectorHeaderTop;
    
    SunlightFactory *sunlightAPI;
    
    int attemptsToGetTransparencyId;
    
    UIColor *textColor;
    UIColor *subTextColor;
    UIColor *headerColor;
    
    NSNumber *leftMargin;
    UIActivityIndicatorView *loading;
}

@end

@implementation PoliticianDetailViewController

@synthesize contactActions;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    leftMargin = @15;
    
    headerColor = [ColorScheme headerColor];
    textColor = [ColorScheme textColor];
    subTextColor = [ColorScheme subTextColor];
    UIColor *backgroundColor = [ColorScheme backgroundColor];
    
    attemptsToGetTransparencyId = 0;
    [self.view setBackgroundColor:backgroundColor];
    self.title = [NSString stringWithFormat:@"%@. %@ %@", politician.title, politician.firstName, politician.lastName];
    
    scrollView = [[UIScrollView alloc] init];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:scrollView];
    
    contentView = [[UIView alloc] init];
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [scrollView addSubview:contentView];
    
    UIImageView *photo = [[UIImageView alloc] init];
//    [photo setBackgroundColor:textColor];
    [photo setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIImage *politicianPhoto = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", politician.bioguideID]];
    [photo setImage:politicianPhoto];
    [photo setContentMode:UIViewContentModeScaleAspectFit];
    [photo setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpg"]]];
    
    double photoSize = 112.5;
    
    UIColor *bgAndBorderColor = textColor;
//    photo.layer.backgroundColor=[bgAndBorderColor CGColor];
    photo.layer.cornerRadius=photoSize/2;
    photo.layer.borderWidth=2.0;
    photo.layer.masksToBounds = YES;
    photo.layer.borderColor=[bgAndBorderColor CGColor];
    
    [contentView addSubview:photo];
    
    if(!politicianPhoto){
        NSLog(@"MISSING PHOTO %@.jpg", politician.bioguideID);
        
        //Set to default image
        UIImage *noPhoto = [UIImage imageNamed:@"MissingImage.png"];
        noPhoto = [noPhoto imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        [photo setImage:noPhoto];
        [photo setTintColor:[ColorScheme placeholderImageColor]];
    }
    
    //Contact Section
    contactSection =[[UIView alloc] init];
    [contactSection setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:contactSection];
    
    //Individual Donors Section
    individualDonorsSection =[[UIView alloc] init];
    [individualDonorsSection setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:individualDonorsSection];
//    [individualDonorsSection setBackgroundColor:[UIColor orangeColor]];
    
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
    NSDictionary *metrics = @{@"sectionPadding": @20,@"lessSectionPadding":@10, @"photoSize": [NSNumber numberWithDouble:photoSize], @"sideMargin":@0};
    
    //Scroll View Layout
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrollView]-0-|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView(==scrollView)]|" options:0 metrics:nil views:views]];
    
    //Entire page layout, vertically
    views = NSDictionaryOfVariableBindings(contentView, photo, contactSection, individualDonorsSection, industryDonorsSection, sectorDonorsSection);
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sectionPadding-[photo(photoSize)]-lessSectionPadding-[contactSection]-sectionPadding-[individualDonorsSection]-sectionPadding-[industryDonorsSection]-sectionPadding-[sectorDonorsSection]|" options:0 metrics:metrics views:views]];
    
    //Photo layout
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:photo attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:photoSize]];
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:photo attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contactSection]-0-|" options:0 metrics:metrics views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[individualDonorsSection]-0-|" options:0 metrics:metrics views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[industryDonorsSection]-0-|" options:0 metrics:metrics views:views]];
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sectorDonorsSection]-0-|" options:0 metrics:metrics views:views]];
    
    [self createContactSection];

    
    
    //Enable sharing actions
    contactActions = [[ContactActionsFactory alloc] init];
    [contactActions setViewController:self];
    
    //Listen for asynchronous callbacks of politician donor data
    topDonorLoaded = @"SunlightFactoryDidReceiveGetTopDonorsForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianData:) name:topDonorLoaded object:nil];
    
    topDonorIndustriesLoaded = @"SunlightFactoryDidReceiveGetTopDonorIndustriesForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianIndustryData:) name:topDonorIndustriesLoaded object:nil];
    
    transparencyIdLoaded = @"SunlightFactoryDidReceiveGetTransparencyIDNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTransparencyId:) name:transparencyIdLoaded object:nil];
    
    topDonorSectorsLoaded = @"SunlightFactoryDidReceiveGetTopDonorSectorsForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianDataSectorData:) name:topDonorSectorsLoaded object:nil];
    
    
    //get transparency id to use in receiving politician donor data
    sunlightAPI = [[SunlightFactory alloc] init];
    [sunlightAPI getLawmakerTransparencyIDFromFirstName:politician.firstName andLastName:politician.lastName];
    
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

-(void)createContactSection{
//    [contactSection setBackgroundColor:[UIColor yellowColor]];
    [contactSection setTranslatesAutoresizingMaskIntoConstraints:NO];
    contactSection.alpha = 0;
    
    NSNumber *halfMargin = @([leftMargin intValue]/2);
    NSDictionary *metrics = @{@"leftMargin":leftMargin, @"buttonSize":@30, @"buttonSpacer":@15, @"topMargin":leftMargin, @"halfMargin":halfMargin};
    
    //create section header
    UILabel *header = [[UILabel alloc] init];
    [header setTextColor:headerColor];
    [header setTranslatesAutoresizingMaskIntoConstraints:NO];
    header.text = @"Contact";
    [header setFont:[UIFont boldSystemFontOfSize:16]];
    [contactSection addSubview:header];

    [contactSection addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[header]-0-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(header)]];
    
    //Add contact card
//    UIView *card = [[UIView alloc] init];
//    [card setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [card setBackgroundColor:[UIColor whiteColor]];
//    [contactSection addSubview:card];
    
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

    
    UIView *buttonsView = [[UIView alloc] init];
    [buttonsView setBackgroundColor:[UIColor whiteColor]];
    [contactSection addSubview:buttonsView];
    [buttonsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contactSection addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[header]-halfMargin-[buttonsView]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(buttonsView, header)]];
    [contactSection addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[buttonsView]-leftMargin-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(buttonsView, header)]];
    
    
    //Create a contact button for each available contact method
    for(int i=0; i<contactMethods.count; i++){
        UIButton *contactButton = [UIButton buttonWithType:UIButtonTypeSystem];//[[UIButton alloc] init];
        
        //set button selector with variable?
        SEL aSelector = NSSelectorFromString([[contactMethods objectAtIndex:i] objectAtIndex:1]);
        [contactButton addTarget:self action:aSelector forControlEvents:UIControlEventTouchDown];
        [contactButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        //Change button color
        UIImage *buttonImage = [UIImage imageNamed:[[contactMethods objectAtIndex:i] objectAtIndex:0]];
        [buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        [contactButton setImage:buttonImage forState:UIControlStateNormal];
        [contactButton setTintColor:[ColorScheme textColor]];
        
        [buttonsView addSubview:contactButton];
        
        if(!leftSide){
            [buttonsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[contactButton(==buttonSize)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(contactButton)]];
        } else {
            [buttonsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftSide]-buttonSpacer-[contactButton(==buttonSize)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(contactButton, leftSide)]];
        }
        [buttonsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[contactButton(==buttonSize)]-topMargin-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(contactButton)]];
        
        
        //Save this button to be used in left positioning the next button
        leftSide = contactButton;
    }
    
    [UIView animateWithDuration:[ColorScheme fadeInTime] animations:^{
        [contactSection setAlpha:1.0f];
    } completion:^(BOOL finished) {}];
}

-(void)createDonorDataSectionWithDonors:(NSArray*)donors andSection:(UIView*)section andTitle:(NSString*)title {
    UILabel *top = [[UILabel alloc] init];
    [top setTextColor:headerColor];
    [top setTranslatesAutoresizingMaskIntoConstraints:NO];
    [top setFont:[UIFont boldSystemFontOfSize:16]];
    [section addSubview:top];
    top.text = title;
    
    UIView *topCard = top;
    
    NSNumber *halfMargin = @([leftMargin intValue]/2);
    NSNumber *quarterMargin = @([halfMargin intValue]/2);
    NSDictionary *metrics = @{@"leftMargin":leftMargin, @"topMargin":halfMargin, @"largeTopMargin":halfMargin, @"sideMargin":@10, @"quarterMargin":quarterMargin};
    
    [section addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[top]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(top)]];
    [section addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[top]-0-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(top)]];
    
    for(int i=0; i<donors.count; i++){
        UIView *card = [[UIView alloc] init];
        [card setTranslatesAutoresizingMaskIntoConstraints:NO];
        [card setBackgroundColor:[ColorScheme cardColor]];
        [section addSubview:card];
        
        NSDictionary *donor = [donors objectAtIndex:i];
        NSString *totalAmount;
        
        if(section == individualDonorsSection){
            totalAmount = [donor objectForKey:@"total_amount"];
        } else if (section == industryDonorsSection || section == sectorDonorsSection){
            totalAmount = [donor objectForKey:@"amount"];
        }
        NSString *donorName = [donor objectForKey:@"name"];
        if(section == sectorDonorsSection){
            donorName = [sunlightAPI convertSectorCode:[donor objectForKey:@"sector"]];
        }
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *total = [numberFormatter numberFromString:totalAmount];
        
        [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        totalAmount = [numberFormatter stringFromNumber:total];
        
        NSString *labelText = donorName;
        
        //If donor is written in ALL CAPS, make it proper nouns (All Caps)
        if ([[labelText uppercaseStringWithLocale:[NSLocale currentLocale]] isEqualToString:labelText])
        {
            labelText = [[labelText lowercaseString] capitalizedString];
        }
        
        //If donor is a person, change formatting from Last, First to First Last
        if([labelText containsString:@","]){
            NSArray *nameSplit = [labelText componentsSeparatedByString:@", "];
            labelText = [NSString stringWithFormat:@"%@ %@", [nameSplit objectAtIndex:1], [nameSplit objectAtIndex:0]];
        }
        
        UILabel *label = [[UILabel alloc] init];
        [label setTextColor:textColor];
        [label setNumberOfLines:0];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        label.text = labelText;
        label.adjustsFontSizeToFitWidth = YES;
        
        UILabel *moneyLabel = [[UILabel alloc] init];
        [moneyLabel setTextColor:subTextColor];
        [moneyLabel setNumberOfLines:0];
        [moneyLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        moneyLabel.text = totalAmount;
        moneyLabel.adjustsFontSizeToFitWidth = YES;
        
        
        NSDictionary *views = NSDictionaryOfVariableBindings(topCard, moneyLabel, label, card);
        
        //Add labels to card
        [card addSubview:label];
        [card addSubview:moneyLabel];
        
        [card addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[label]-quarterMargin-[moneyLabel]-topMargin-|" options:0 metrics:metrics views:views]];
        [card addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[label]-leftMargin-|" options:0 metrics:metrics views:views]];
        [card addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[moneyLabel]-leftMargin-|" options:0 metrics:metrics views:views]];
        
        if(donors.count-1 == i){
            [section addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topCard]-largeTopMargin-[card]-|" options:0 metrics:metrics views:views]];
        } else {
            [section addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topCard]-largeTopMargin-[card]" options:0 metrics:metrics views:views]];
        }
        [section addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[card]-leftMargin-|" options:0 metrics:metrics views:views]];
        
        topCard = card;
    }
    
    
    [loading stopAnimating];
    [UIView animateWithDuration:[ColorScheme fadeInTime] animations:^{
        [section setAlpha:1.0f];
    } completion:^(BOOL finished) {}];
}

- (void)didReceivePoliticianData:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSArray *donors = [userInfo objectForKey:@"results"];
    
    topDonorLoaded = @"SunlightFactoryDidReceiveGetTopDonorsForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:topDonorLoaded object:nil];
    
    [individualDonorsSection setAlpha:0.0f];
    [self createDonorDataSectionWithDonors:donors andSection:individualDonorsSection andTitle:@"Top Individual Donors"];
}

-(void)didReceivePoliticianIndustryData:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSArray *donorIndustries = [userInfo objectForKey:@"results"];
    
    topDonorIndustriesLoaded = @"SunlightFactoryDidReceiveGetTopDonorIndustriesForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:topDonorIndustriesLoaded object:nil];
    
    [industryDonorsSection setAlpha:0.0f];
    [self createDonorDataSectionWithDonors:donorIndustries andSection:industryDonorsSection andTitle:@"Top Donors by Industry"];
}

-(void)didReceivePoliticianDataSectorData:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSArray *donorSectors = [userInfo objectForKey:@"results"];
    
    topDonorSectorsLoaded = @"SunlightFactoryDidReceiveGetTopDonorSectorsForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:topDonorSectorsLoaded object:nil];
    
    [sectorDonorsSection setAlpha:0.0f];
    [self createDonorDataSectionWithDonors:donorSectors andSection:sectorDonorsSection andTitle:@"Top Donors by Sector"];
}

-(void)didReceiveTransparencyId:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSArray *politicians = [userInfo objectForKey:@"results"];
    
    attemptsToGetTransparencyId++;
    
    if(politicians.count > 0){
        NSString *transparencyID = [[politicians objectAtIndex:0] objectForKey:@"id"];
        
        transparencyIdLoaded = @"SunlightFactoryDidReceiveGetTransparencyIDNotification";
        [[NSNotificationCenter defaultCenter] removeObserver:self name:transparencyIdLoaded object:nil];
        
        [sunlightAPI getTopDonorsForLawmaker:transparencyID];
        [sunlightAPI getTopDonorIndustriesForLawmaker:transparencyID];
        [sunlightAPI getTopDonorSectorsForLawmaker:transparencyID];
    } else {
        NSLog(@"[PoliticianDetailViewController.m] WARNING: Politician not found while checking for transparency id - Donation data will not be shown");
        
        if(attemptsToGetTransparencyId < 2){
            NSString *shortenedFirstName = [politician.firstName substringToIndex:3];
            [sunlightAPI getLawmakerTransparencyIDFromFirstName:shortenedFirstName andLastName:politician.lastName];
        } else {
            transparencyIdLoaded = @"SunlightFactoryDidReceiveGetTransparencyIDNotification";
            [[NSNotificationCenter defaultCenter] removeObserver:self name:transparencyIdLoaded object:nil];
        }
        
    }
}

#pragma mark - Contact Delegate Methods
-(void)TEST{
    NSLog(@"TEST");
}

-(void)sendEmail {
    [contactActions composeEmail:politician.email];
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

-(void)dealloc{
    topDonorLoaded = @"SunlightFactoryDidReceiveGetTopDonorsForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:topDonorLoaded object:nil];
    
    topDonorIndustriesLoaded = @"SunlightFactoryDidReceiveGetTopDonorIndustriesForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:topDonorIndustriesLoaded object:nil];
    
    transparencyIdLoaded = @"SunlightFactoryDidReceiveGetTransparencyIDNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:transparencyIdLoaded object:nil];
    
    topDonorSectorsLoaded = @"SunlightFactoryDidReceiveGetTopDonorSectorsForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:topDonorSectorsLoaded object:nil];
}

@end
