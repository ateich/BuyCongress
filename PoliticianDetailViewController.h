//
//  PoliticianDetailViewController.h
//  MyCongress
//
//  Created by HackReactor on 1/6/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Politician.h"
#import "ContactActionsFactory.h"

@interface PoliticianDetailViewController : UIViewController
@property (strong, nonatomic) ContactActionsFactory *contactActions;

-(void)setPolitician:(Politician *)newPolitician;

@end
