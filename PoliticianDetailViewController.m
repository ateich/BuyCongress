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
    
    /* LAYOUT CONSTRAINTS */
    int leftMargin;
    int sectionVerticalMargin;
    int subSectionVerticalMargin;
}

@end

@implementation PoliticianDetailViewController

//REFACTOR THIS TO BE SHORTER
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    int topBarHeight = 20 + self.navigationController.navigationBar.frame.size.height;
    
    photo = [[UIImageView alloc] init];
    [photo setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:photo];
    
    self.title = [NSString stringWithFormat:@"%@. %@ %@", politician.title, politician.firstName, politician.lastName];
    
    /* LAYOUT CONSTRAINTS */
    leftMargin = 25;
    sectionVerticalMargin = 25;
    subSectionVerticalMargin = sectionVerticalMargin/2;
    
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
    
    id partyStateHeader = [self createHeaderSectionBelow:photo withName:[NSString stringWithFormat:@"%@ - %@", politician.party, politician.state] andLeftMargin:0 aligned:NSTextAlignmentCenter];
    
    id contactHeader = [self createHeaderSectionBelow:partyStateHeader withName:@"Contact" andLeftMargin:leftMargin aligned:NSTextAlignmentLeft];
    id contactButtons = [self createContactButtonSection:contactHeader];

    id donorHeader = [self createHeaderSectionBelow:contactButtons withName:@"Donors" andLeftMargin:leftMargin aligned:NSTextAlignmentLeft];
    
    
    //TESTING
    [photo setBackgroundColor:[UIColor blackColor]];
}

-(id)createHeaderSectionBelow:(id)itemAbove withName:(NSString*)title andLeftMargin:(int)leftHandMargin aligned:(NSTextAlignment)alignment{
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
    
    return header;
}

/** 
 * Creates contact buttons below itemAbove and returns an id that can be used to position elements after this section
 */
-(id)createContactButtonSection:(id)itemAbove {
    //Check which contact information the Politician has
    NSMutableArray *contactMethods = [[NSMutableArray alloc] init];
    
    if(politician.twitter){
        [contactMethods addObject:@"twitter"];
    }
    if(politician.youtubeID){
        [contactMethods addObject:@"youtube"];
    }
    if(politician.phone){
        [contactMethods addObject:@"phone"];
    }
    if(politician.email){
        [contactMethods addObject:@"email"];
    }
    if(politician.website){
        [contactMethods addObject:@"website"];
    }
    
    
    id leftSide;
    int buttonSize = 30;
    
    //Create a contact button for each available contact method
    for(int i=0; i<contactMethods.count; i++){
        UIButton *contactButton = [[UIButton alloc] init];
        [self.view addSubview:contactButton];
        
        [contactButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [contactButton setBackgroundImage:[UIImage imageNamed:[contactMethods objectAtIndex:i]] forState:UIControlStateNormal];
        
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setPolitician:(Politician *)newPolitician{
    politician = newPolitician;
}

@end
