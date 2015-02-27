//
//  InfluenceExplorerViewController.m
//  MyCongress
//
//  Created by HackReactor on 2/26/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "InfluenceExplorerViewController.h"
#import "ColorScheme.h"

@interface InfluenceExplorerViewController (){
    NSMutableArray *instructions;
}

@end

@implementation InfluenceExplorerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setInstructions];
    
    [[UIPageControl appearance] setBackgroundColor:[ColorScheme headerColor]];
    [[UIPageControl appearance] setPageIndicatorTintColor:[ColorScheme backgroundColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor:[ColorScheme navBarColor]];
    
    [self.view setBackgroundColor:[ColorScheme headerColor]];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    PageViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}

-(void)setInstructions{
    instructions = [[NSMutableArray alloc] init];
    [instructions addObject:@"Influence Explorer"];
    [instructions addObject:@"1. Press the share button"];
    [instructions addObject:@"2. Swipe left and tap More"];
    [instructions addObject:@"3. Switch Influence Explorer On"];
    [instructions addObject:@"Tap Influence Explorer"];
    [instructions addObject:@"Follow the money"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(PageViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(PageViewController *)viewController index];
    index++;
    
    if (index == 6) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (PageViewController *)viewControllerAtIndex:(NSUInteger)index {
    PageViewController *childViewController = [[PageViewController alloc] init];
    childViewController.index = index;
    childViewController.instruction = [instructions objectAtIndex:index];
    return childViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 6;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

@end
