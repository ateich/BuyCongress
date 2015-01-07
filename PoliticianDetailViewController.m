//
//  PoliticianDetailViewController.m
//  MyCongress
//
//  Created by HackReactor on 1/6/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "PoliticianDetailViewController.h"

//May need to change this to a scrollview, or add a scrollview to it
@interface PoliticianDetailViewController (){
    Politician *politician;
    UIImageView *photo;
    UILabel *partyState;
    UILabel *contactHeader;
    UILabel *donorsHeader;
}

@end

@implementation PoliticianDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor redColor]];
    int topBarHeight = 20 + self.navigationController.navigationBar.frame.size.height;
    
    photo = [[UIImageView alloc] init];
    partyState = [[UILabel alloc] init];
    contactHeader = [[UILabel alloc] init];
    donorsHeader = [[UILabel alloc] init];
    
    [photo setTranslatesAutoresizingMaskIntoConstraints:NO];
    [partyState setTranslatesAutoresizingMaskIntoConstraints:NO];
    [contactHeader setTranslatesAutoresizingMaskIntoConstraints:NO];
    [donorsHeader setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:photo];
    [self.view addSubview:partyState];
    [self.view addSubview:contactHeader];
    [self.view addSubview:donorsHeader];
    
    contactHeader.text = @"Contact";
    donorsHeader.text = @"Donors";
    [partyState setTextAlignment:NSTextAlignmentCenter];
    
    /* LAYOUT CONSTRAINTS */
    int leftMargin = 25;
    int sectionVerticalMargin = 25;
    int headerHeight = 25;
    
    //Photo Layout Constraints
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
    
    //partyState Layout Constraints
    NSLayoutConstraint *partyStateTopConstraint = [NSLayoutConstraint constraintWithItem:partyState attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:photo attribute:NSLayoutAttributeBottom multiplier:1.0 constant:sectionVerticalMargin];
    NSLayoutConstraint *partyStateCenterConstraint = [NSLayoutConstraint constraintWithItem:partyState attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *partyStateHeightConstraint = [NSLayoutConstraint constraintWithItem:partyState attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:headerHeight];
    NSLayoutConstraint *partyStateWidthConstraint = [NSLayoutConstraint constraintWithItem:partyState attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    
    [self.view addConstraint:partyStateTopConstraint];
    [self.view addConstraint:partyStateCenterConstraint];
    [self.view addConstraint:partyStateHeightConstraint];
    [self.view addConstraint:partyStateWidthConstraint];
    
    //contactHeader Layout Constraints
    NSLayoutConstraint *contactHeaderTopConstraint = [NSLayoutConstraint constraintWithItem:contactHeader attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:partyState attribute:NSLayoutAttributeBottom multiplier:1.0 constant:sectionVerticalMargin];
    NSLayoutConstraint *contactHeaderLeftConstraint = [NSLayoutConstraint constraintWithItem:contactHeader attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:leftMargin];
    NSLayoutConstraint *contactHeaderWidthConstraint = [NSLayoutConstraint constraintWithItem:contactHeader attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *contactHeaderHeightConstraint = [NSLayoutConstraint constraintWithItem:contactHeader attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:headerHeight];
    
    [self.view addConstraint:contactHeaderTopConstraint];
    [self.view addConstraint:contactHeaderLeftConstraint];
    [self.view addConstraint:contactHeaderWidthConstraint];
    [self.view addConstraint:contactHeaderHeightConstraint];
    
    //donorsHeader Layout Constraints
    NSLayoutConstraint *donorsHeaderTopConstraint = [NSLayoutConstraint constraintWithItem:donorsHeader attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contactHeader attribute:NSLayoutAttributeBottom multiplier:1.0 constant:sectionVerticalMargin];
    NSLayoutConstraint *donorsHeaderLeftConstraint = [NSLayoutConstraint constraintWithItem:donorsHeader attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:leftMargin];
    NSLayoutConstraint *donorsHeaderWidthConstraint = [NSLayoutConstraint constraintWithItem:donorsHeader attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *donorsHeaderHeightConstraint = [NSLayoutConstraint constraintWithItem:donorsHeader attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:headerHeight];
    
    [self.view addConstraint:donorsHeaderTopConstraint];
    [self.view addConstraint:donorsHeaderLeftConstraint];
    [self.view addConstraint:donorsHeaderWidthConstraint];
    [self.view addConstraint:donorsHeaderHeightConstraint];
    
    /* END OF LAYOUT CONSTRAINTS */
    
    //TESTING
    [photo setBackgroundColor:[UIColor blackColor]];
    
    [self refreshViewData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setPolitician:(Politician *)newPolitician{
    politician = newPolitician;
    [self refreshViewData];
}

-(void)refreshViewData {
    if(politician){
        self.title = [NSString stringWithFormat:@"%@. %@ %@", politician.title, politician.firstName, politician.lastName];
        partyState.text = [NSString stringWithFormat:@"%@ - %@", politician.party, politician.state];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
