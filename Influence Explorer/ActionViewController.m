//
//  ActionViewController.m
//  Influence Explorer
//
//  Created by HackReactor on 1/22/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Tokens.h"
#import "ReadabilityFactory.h"
#import "SunlightFactory.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorScheme.h"
#import <objc/runtime.h>

@interface ActionViewController (){
    ReadabilityFactory *readabilityFactory;
    SunlightFactory *sunlightAPI;
    UIScrollView *scrollView;
    UIView *contentView;
    UIView *bottomCard;
    NSArray *bottomMostConstraints;
    NSString *topDonorIndustriesLoaded;
    
    NSMutableDictionary *cardDonorIndustryLabels;
    NSMutableArray *politicainsFound;
    NSMutableArray *organizationsFound;
    
    NSMutableDictionary *organizationDonations;
    
    UIActivityIndicatorView *loading;
}

//@property(strong,nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ActionViewController{
    
}

//static UIStatusBarStyle statusBarStyle;
//
//static UIStatusBarStyle preferredStatusBarStyle(id self, SEL _cmd)
//{
//    return statusBarStyle;
//}
//
//void setPreferredStatusBarStyleOnRootVC(UIStatusBarStyle style, UIViewController *vc)
//{
//    statusBarStyle = style;
//    static BOOL swizzeld = NO;
//    if(swizzeld)
//    {
//        [vc setNeedsStatusBarAppearanceUpdate];
//        return;
//    }
//    
//    swizzeld = YES;
//    
//    UIViewController *parent;
//    while((parent = vc.parentViewController))
//        vc = parent;
//    
//    class_addMethod(vc.class, @selector(preferredStatusBarStyle), (IMP)&preferredStatusBarStyle, "v@:");
//}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReadabilityFactoryDidReceiveReadableArticleNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SunlightFactoryDidReceiveSearchForEntityNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SunlightFactoryDidReceiveGetTopDonorIndustriesForLawmakerNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SunlightFactoryDidReceiveGetContributionsFromOrganizationToPoliticianNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    statusBarStyle = UIStatusBarStyleLightContent;
    
    [self.view setBackgroundColor:[ColorScheme backgroundColor]];
    
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBarTintColor:[ColorScheme navBarColor]];
    
    
    //set nav bar back button and text color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    cardDonorIndustryLabels = [[NSMutableDictionary alloc] init];
    politicainsFound = [[NSMutableArray alloc] init];
    organizationsFound = [[NSMutableArray alloc] init];
    organizationDonations = [[NSMutableDictionary alloc] init];
    
    readabilityFactory = [[ReadabilityFactory alloc] init];
    sunlightAPI = [[SunlightFactory alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveReadableArticle:) name:@"ReadabilityFactoryDidReceiveReadableArticleNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveEntityData:) name:@"SunlightFactoryDidReceiveSearchForEntityNotification" object:nil];
    
    topDonorIndustriesLoaded = @"SunlightFactoryDidReceiveGetTopDonorIndustriesForLawmakerNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticianIndustryData:) name:topDonorIndustriesLoaded object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveContributionDataFromOrganizationToPolitician:) name:@"SunlightFactoryDidReceiveGetContributionsFromOrganizationToPoliticianNotification" object:nil];
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
                    if(url) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [self parseUrlForArticle:url];
                        }];
                    } else if(error){
                        NSLog(@"%@", [error description]);
                    }
                }];
                break;
            }
        }
    }
    
    scrollView = [[UIScrollView alloc] init];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:scrollView];
//        [scrollView setBackgroundColor:[UIColor greenColor]];
    
    contentView = [[UIView alloc] init];
//        [contentView setBackgroundColor:[UIColor purpleColor]];
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [scrollView addSubview:contentView];
    
    //AUTO LAYOUT (VFL)
    NSDictionary *views = NSDictionaryOfVariableBindings(scrollView, contentView);
    NSNumber *topMargin = [NSNumber numberWithDouble: _navBar.frame.size.height + _navBar.frame.origin.y];
    NSDictionary *metrics = @{@"topMargin": topMargin, @"sectionPadding": @20};
    
    //Scroll View Layout
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[scrollView]-0-|" options:0 metrics:metrics views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView(==scrollView)]|" options:0 metrics:nil views:views]];
    
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

-(void)parseUrlForArticle:(NSURL*)url{
    NSString *apiUrl = [NSString stringWithFormat:@"https://readability.com/api/content/v1/parser?url=%@?currentPage=all&token=%@", [url absoluteString], [Tokens getReadabilityToken]];
    [readabilityFactory makeReadableArticleFromUrl:apiUrl];
}

-(void)didReceiveReadableArticle:(NSNotification*)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReadabilityFactoryDidReceiveReadableArticleNotification" object:nil];
    
    NSDictionary *userInfo = [notification userInfo];
    NSString *articleHTML = [[userInfo objectForKey:@"content"] objectForKey:@"content"];
    
    //contains a dictionary of keys: word types and values: dictionary of words
    NSMutableDictionary *properNouns = [self parseReadableArticleForProperNouns:articleHTML];
    [self checkIfProperNounsArePoliticians:[properNouns objectForKey:@"PersonalName"]];
}

-(void)checkIfProperNounsArePoliticians:(NSMutableDictionary*)properNouns{
    if(properNouns){
        for (NSString *person in properNouns) {
            //check if this person is a recognized politician
            //doing this check locally would greatly increase performance
            //vs making an api call for each person to verify they are a politican
            //  then making additional transparency calls for each verified person
            [sunlightAPI searchForEntity:person];
        }
    }
}

-(void)didReceiveEntityData:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSArray *politicians = [userInfo objectForKey:@"results"];
    
    if(politicians.count > 0){
        
        //find the first non-individual
        //  if no non-individuals found, do nothing
        int foundNonIndividualAtPosition = -1;
        for (int i=0; i<politicians.count; i++) {
            if(![[[politicians objectAtIndex:i] objectForKey:@"type"] isEqualToString:@"individual"]){
                foundNonIndividualAtPosition = i;
                break;
            }
        }
        
        if(foundNonIndividualAtPosition >= 0){
            NSMutableDictionary *politicianDict = [politicians objectAtIndex:0];
            NSString *name = [politicianDict objectForKey:@"name"];
            
            //compare number of words in original query and result to remove innacurate results
            NSNumber *numberOfWordsInQuery = [userInfo objectForKey:@"numberOfWordsInQuery"];
            long wordsInResult = [[name componentsSeparatedByString:@" "] count] -1;
            
            int threshold = 2;
            if(wordsInResult <= [numberOfWordsInQuery intValue] + threshold){
                
                //What do I do once I have received a result?
                //Display it in a card.
                [self createCardWithBasicInformation:politicianDict];
                
                if([[politicianDict objectForKey:@"type"] isEqualToString:@"politician"]){
                    NSString *transparencyID = [politicianDict objectForKey:@"id"];
                    
                    [politicainsFound addObject:[politicianDict objectForKey:@"name"]];
                
                    //        [sunlightAPI getTopDonorsForLawmaker:transparencyID];
                    [sunlightAPI getTopDonorIndustriesForLawmaker:transparencyID];
                    //        [sunlightAPI getTopDonorSectorsForLawmaker:transparencyID];
                    
                    NSArray *organizationsFoundSoFar = [NSArray arrayWithArray:organizationsFound];
                    //for each organization that has already been created as a card
                    for (int i=0; i<organizationsFoundSoFar.count; i++) {
                        [sunlightAPI getContributionsFromOrganization:[organizationsFoundSoFar objectAtIndex:i] ToPolitician:name];
                    }
                    
                } else if([[politicianDict objectForKey:@"type"] isEqualToString:@"organization"]){
                    NSArray *politiciansFoundSoFar = [NSArray arrayWithArray:politicainsFound];
                    //make API call to see if each politician found so far was donated money from this organization
                    for (int i=0; i<politiciansFoundSoFar.count; i++) {
                        //make api call here
                        [sunlightAPI getContributionsFromOrganization:name ToPolitician:[politiciansFoundSoFar objectAtIndex:i]];
                    }
                    [organizationsFound addObject:name];
                }
            }
        }
        
    } else {
        NSLog(@"[PoliticianDetailViewController.m] WARNING: Politician not found while checking for transparency id - Donation data will not be shown");
    }
}

-(void)didReceiveContributionDataFromOrganizationToPolitician:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    
    NSString *politician = [userInfo objectForKey:@"politician"];
    NSString *organization = [userInfo objectForKey:@"organization"];
    NSArray *donations = [userInfo objectForKey:@"results"];
    
    double totalDonated = 0;
    for (int i=0; i<donations.count; i++) {
        totalDonated += [[[donations objectAtIndex:i] objectForKey:@"amount"] doubleValue];
    }
    
    if(totalDonated > 0){
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        NSString *total = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:totalDonated]];
        
        NSMutableDictionary *organizationDict = [organizationDonations objectForKey:[organization capitalizedString]];
        UILabel *container = [organizationDict objectForKey:@"superView"];
        
        UILabel *headerLabel = [[UILabel alloc] init];
        headerLabel.numberOfLines = 0;
        [headerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [headerLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [headerLabel setTextColor:[ColorScheme textColor]];
        headerLabel.text  = @"Donated to Politicians";
        [container addSubview:headerLabel];
        
        UILabel *politicianLabel = [[UILabel alloc] init];
        politicianLabel.numberOfLines = 0;
        [politicianLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [politicianLabel setFont:[UIFont systemFontOfSize:14]];
        [politicianLabel setTextColor:[ColorScheme textColor]];
        politicianLabel.text  = politician;
        [container addSubview:politicianLabel];
        
        UILabel *donationLabel = [[UILabel alloc] init];
        donationLabel.numberOfLines = 0;
        [donationLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [donationLabel setFont:[UIFont systemFontOfSize:14]];
        [donationLabel setTextColor:[ColorScheme subTextColor]];
        donationLabel.text  = total;
        [container addSubview:donationLabel];
        
        //VFL
        
        UILabel *lowestDonationVertically = [organizationDict objectForKey:@"lowestView"];
        NSDictionary *metrics = @{@"topMargin":@7.5};
        
        NSDictionary *views = NSDictionaryOfVariableBindings(headerLabel, politicianLabel, donationLabel);
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[headerLabel]-|" options:0 metrics:nil views:views]];
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[politicianLabel]-|" options:0 metrics:nil views:views]];
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[donationLabel]-|" options:0 metrics:nil views:views]];
        
        if ([organizationDict objectForKey:@"bottomConstraint"]) {
            //remove old bottom constraint
            NSLayoutConstraint *bottomConstraint = [organizationDict objectForKey:@"bottomConstraint"];
            [container removeConstraint:bottomConstraint];
        }
        
        if(!lowestDonationVertically){
            NSArray *bottomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[headerLabel]-[politicianLabel]-[donationLabel]" options:0 metrics:nil views:views];
            [container addConstraints:bottomConstraints];
        } else {
            views = NSDictionaryOfVariableBindings(donationLabel, lowestDonationVertically);
            [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lowestDonationVertically]-topMargin-[headerLabel]-[politicianLabel]-[donationLabel]" options:0 metrics:metrics views:views]];
        }
        
        NSArray *bottomConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[donationLabel]-|" options:0 metrics:nil views:views];
        [container addConstraints:bottomConstraint];
//        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[donationLabel]-|" options:0 metrics:nil views:views]];
        
        [organizationDict setObject:donationLabel forKey:@"lowestView"];
        [organizationDict setObject:bottomConstraint forKey:@"bottomConstraint"];
        
        [UIView animateWithDuration:[ColorScheme fadeInTime] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            container.alpha = 1;
        } completion:^(BOOL finished){}];
    }
}

-(void)didReceivePoliticianIndustryData:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSString *callingLawmakerId = [userInfo objectForKey:@"callingLawmakerId"];
    NSArray *donorIndustries = [userInfo objectForKey:@"results"];
    
    NSString *topDonorIndustriesHeader = @"Top Contributing Industries";
    NSString *topDonorIndustries = @"";
    bool showDonors = NO;
    
    //if there are donors, only show the top 3
    if(donorIndustries.count >= 3){
        showDonors = YES;
        for (int i=0; i<3; i++) {
            topDonorIndustries = [NSString stringWithFormat:@"%@%@, ", topDonorIndustries, [[[donorIndustries objectAtIndex:i] objectForKey:@"name"] capitalizedString]];
        }
    }
    
    if(showDonors){
        topDonorIndustries = [topDonorIndustries substringToIndex:[topDonorIndustries length]-2];
        
        UIView *container = [cardDonorIndustryLabels objectForKey:callingLawmakerId];
        
        UILabel *headerLabel = [[UILabel alloc] init];
        [headerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [headerLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [headerLabel setTextColor:[ColorScheme textColor]];
        headerLabel.text = topDonorIndustriesHeader;
        headerLabel.numberOfLines = 0;
        [container addSubview:headerLabel];
        
        UILabel *donorsLabel = [[UILabel alloc] init];
        [donorsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [donorsLabel setFont:[UIFont systemFontOfSize:14]];
        [donorsLabel setTextColor:[ColorScheme subTextColor]];
        donorsLabel.text = topDonorIndustries;
        donorsLabel.numberOfLines = 0;
        [container addSubview:donorsLabel];
        
        
        NSDictionary *views = NSDictionaryOfVariableBindings(headerLabel, donorsLabel);
        NSDictionary *metrics = @{@"cardMargin": @15, @"verticalMargin":@7.5};
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[headerLabel]-[donorsLabel]-|" options:0 metrics:metrics views:views]];
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[headerLabel]-|" options:0 metrics:metrics views:views]];
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[donorsLabel]-|" options:0 metrics:metrics views:views]];
        
        [UIView animateWithDuration:[ColorScheme fadeInTime] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            container.alpha = 1;
        } completion:^(BOOL finished){}];
    }
}

-(void)createCardWithBasicInformation:(NSMutableDictionary*)data{
    [loading stopAnimating];
    
    UIView *card = [[UIView alloc] init];
    [card setBackgroundColor:[UIColor whiteColor]];
    [card setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contentView addSubview:card];
//    card.layer.cornerRadius = 5;
//    card.clipsToBounds = YES;
    card.alpha = 0;
    
    NSMutableString *nameString = [data objectForKey:@"name"];
    
    NSArray *splitByComma = [nameString componentsSeparatedByString:@","];
    if(splitByComma.count == 2){
        nameString = [NSMutableString stringWithFormat:@"%@ %@", [[splitByComma objectAtIndex:1] substringFromIndex:1], [splitByComma objectAtIndex:0]];
    }
    nameString = [NSMutableString stringWithString:[nameString capitalizedString]];
    
    //remove anything between parentheses
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"\\(.+?\\)"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:NULL];
    
    [regex replaceMatchesInString:nameString options:0 range:NSMakeRange(0, [nameString length]) withTemplate:@""];
    
    UILabel *name = [[UILabel alloc] init];
    [name setTranslatesAutoresizingMaskIntoConstraints:NO];
    [name setFont:[UIFont boldSystemFontOfSize:16]];
    [name setTextColor:[ColorScheme headerColor]];
    [name setNumberOfLines:0];
    [name setText:nameString];
    [card addSubview:name];
    
    UIView *donorView = [[UIView alloc] init];
    [donorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    donorView.alpha = 0;
    [card addSubview:donorView];
    
    [cardDonorIndustryLabels setObject:donorView forKey:[data objectForKey:@"id"]];
    
    NSMutableDictionary *viewAndConstraints = [[NSMutableDictionary alloc] init];
    [viewAndConstraints setObject:donorView forKey:@"superView"];
    
    [organizationDonations setObject:viewAndConstraints forKey:nameString];
    
    NSDictionary *views;
    NSDictionary *metrics = @{@"cardMargin": @15, @"verticalMargin":@7.5};
    
    //Add card to view
    //if this card will be the first card on screen, bind it to the top
    if(!bottomCard){
        views = NSDictionaryOfVariableBindings(card, name, donorView);
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-verticalMargin-[card]" options:0 metrics:metrics views:views]];
    } else {
        views = NSDictionaryOfVariableBindings(card, name, bottomCard, donorView);
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomCard]-verticalMargin-[card]" options:0 metrics:metrics views:views]];
    }
    
    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-cardMargin-[card]-cardMargin-|" options:0 metrics:metrics views:views]];
    
    [contentView removeConstraints:bottomMostConstraints];
    bottomMostConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[card]-verticalMargin-|" options:0 metrics:metrics views:views];
    [contentView addConstraints:bottomMostConstraints];
    bottomCard = card;
    
    
    //Add data to card
    views = NSDictionaryOfVariableBindings(card, name, donorView);
    [card addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-cardMargin-[name]" options:0 metrics:metrics views:views]];
    [card addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-cardMargin-[name]-cardMargin-|" options:0 metrics:metrics views:views]];
    
    [card addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[name]-[donorView]-|" options:0 metrics:metrics views:views]];
    [card addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[donorView]-|" options:0 metrics:metrics views:views]];
    
//    [donorView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[industryDonors]-|" options:0 metrics:metrics views:views]];
//    [donorView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"" options:0 metrics:metrics views:views]];
    
    //STRICTLY FOR SCROLLVIEW TESTING - DELETE LATER
//    [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[card(==100)]" options:0 metrics:nil views:views]];
    
    //Animate card appearing
    [UIView animateWithDuration:[ColorScheme fadeInTime] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        card.alpha = 1;
     } completion:^(BOOL finished){}];
    
    //Add a shadow to the card
//    card.layer.masksToBounds = NO;
//    card.layer.shadowOffset = CGSizeMake(0, 3);
//    card.layer.shadowRadius = 3;
//    card.layer.shadowOpacity = 0.5;
}

-(NSMutableDictionary*)parseReadableArticleForProperNouns:(NSString*)content{
    NSMutableDictionary *properNouns = [[NSMutableDictionary alloc] init];
    
    //strip out all HTML tags and political titles
    content = [self stringByStrippingHTML:content];
    content = [self stringByStrippingLocations:content];
    content = [self removePoliticalTitles:content];
    
    //Get all names of people and organizations with NSLinguisticTagger
    NSLinguisticTaggerOptions tagOptions = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:[NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:tagOptions];
    tagger.string = content;
    
    [tagger enumerateTagsInRange:NSMakeRange(0, [content length]) scheme:NSLinguisticTagSchemeNameType options:tagOptions usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
        NSString *token = [content substringWithRange:tokenRange];
        if(![tag isEqualToString:@"OtherWord"]){
            if(![properNouns objectForKey:tag]){
                [properNouns setObject:[[NSMutableDictionary alloc] init] forKey:tag];
            }
            [[properNouns objectForKey:tag] setObject:@YES forKey:token];
        }
    }];
    return properNouns;
}

-(NSString*)removePoliticalTitles:(NSString*)content{
    NSMutableArray *wordsToRemove = [[NSMutableArray alloc] init];
    [wordsToRemove addObjectsFromArray:[[NSArray alloc] initWithObjects:
                                        @"Sen",
                                        @"Rep",
                                        @"Speaker",
                                        @"Leader",
                                        @"Whip",
                                        @"Chairman",
                                        @"Mayor",
                                        nil]];
    
    for(int i=0; i<wordsToRemove.count; i++){
        content = [content stringByReplacingOccurrencesOfString:[wordsToRemove objectAtIndex:i] withString:@". "];
    }
    
    //These replacements were arrived upon by trial and error through testing articles on numerous websites
    content = [content stringByReplacingOccurrencesOfString:@"." withString:@" .. "];
    content = [content stringByReplacingOccurrencesOfString:@"of" withString:@"-"];
    
    return content;
}

-(NSString*)stringByStrippingHTML:(NSString*)s {
    NSRange r;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

-(NSString*)stringByStrippingLocations:(NSString*)s{
//    /(\b of \b)([A-Z]\w+) ([A-Z]\w+)?
    NSRange r;
    while ((r = [s rangeOfString:@"(\\b of \\b)([A-Z]\\w+) ([A-Z]\\w+)?" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@" .. "];
    return s;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
