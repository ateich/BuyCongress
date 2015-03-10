//
//  PoliticianTableViewController.h
//  MyCongress
//
//  Created by HackReactor on 1/5/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PoliticianTableViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *politicians;

-(void)updateTableViewWithNewData:(NSMutableArray*)data;
-(NSMutableArray *)createPoliticiansFromDataArray:(NSArray *)politicianData;
-(void)useFadeInAnimation:(bool)fadeIn;
-(void)hideSectionIndexBar:(BOOL)hide;

@end
