//
//  InfluenceExplorerViewController.h
//  MyCongress
//
//  Created by HackReactor on 2/26/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"

@interface InfluenceExplorerViewController : UIViewController<UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageController;

@end
