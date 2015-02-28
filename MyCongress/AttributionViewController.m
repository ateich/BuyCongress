//
//  AttributionViewController.m
//  MyCongress
//
//  Created by HackReactor on 2/26/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "AttributionViewController.h"
#import "ColorScheme.h"

@interface AttributionViewController (){
    UIScrollView *scrollView;
    UIView *contentView;
}

@end

@implementation AttributionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *statusBarBackground = [[UIView alloc] init];
    [statusBarBackground setTranslatesAutoresizingMaskIntoConstraints:NO];
    [statusBarBackground setBackgroundColor:[ColorScheme navBarColor]];
    [self.view addSubview:statusBarBackground];
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [navBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    navBar.backgroundColor = [UIColor whiteColor];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Attributions";
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(closeView:)];
    navItem.rightBarButtonItem = rightButton;
    navBar.items = @[ navItem ];
    
    [self.view addSubview:navBar];
    
    //Set up scroll view
    scrollView = [[UIScrollView alloc] init];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:scrollView];
    
    contentView = [[UIView alloc] init];
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [scrollView addSubview:contentView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(scrollView, contentView, navBar, statusBarBackground);
    NSNumber *statusBarHeight = [NSNumber numberWithDouble:[UIApplication sharedApplication].statusBarFrame.size.height];
    NSNumber *verticalMargin = [NSNumber numberWithInt:10];
    NSNumber *topMargin = [NSNumber numberWithDouble:[statusBarHeight doubleValue] + [verticalMargin doubleValue]];
    NSDictionary *metrics = @{@"statusBarHeight": statusBarHeight, @"verticalMargin":verticalMargin, @"topMargin":topMargin};
    
    //Scroll View Layout
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[navBar]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[statusBarBackground]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[statusBarBackground(==20)]-0-[navBar]-[scrollView]-0-|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|" options:0 metrics:nil views:views]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView(==scrollView)]|" options:0 metrics:nil views:views]];
    
    [self.view setBackgroundColor:[ColorScheme backgroundColor]];
    [contentView setBackgroundColor:[ColorScheme backgroundColor]];
    
    NSArray *attributions = [NSArray arrayWithObjects:
                             @"Flatwork color palette created by ghepting at http://www.colourlovers.com/palette/2840713/Flatwork",
                             @"Federal campaign contribution records provided by OpenSecrets.org",
                             @"State campaign contribution records provided by FollowTheMoney.com",
                             @"Politician and organization data is accessed through the Sunlight Foundation's Transparency Data and Transparency Data APIs",
                             @"All data licensed under a Creative Commons BY-NC-SA license",
                             @"Photos of members of Congress are from the Government Printing Office and are public domain",
                             @"All other images © 2015 Cybellion LLC",
                             @"The source code of this application is open source and available at https://github.com/ateich/BuyCongress",
                             nil];
    
    UITextView *bottom;
    
    for (int i=0; i<attributions.count; i++) {
        UITextView *attribution = [[UITextView alloc] init];
        [attribution setScrollEnabled:NO];
        [attribution setTextColor:[ColorScheme textColor]];
        [attribution setEditable:NO];
        [attribution setDataDetectorTypes:UIDataDetectorTypeLink];
        [attribution setFont:[UIFont systemFontOfSize:12]];
        [attribution setTranslatesAutoresizingMaskIntoConstraints:NO];
        attribution.text = [attributions objectAtIndex:i];
        [contentView addSubview:attribution];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(attribution);
        
        if(!bottom){
            [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-verticalMargin-[attribution]" options:0 metrics:metrics views:views]];
        } else {
            views = NSDictionaryOfVariableBindings(attribution, bottom);
            [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottom]-verticalMargin-[attribution]" options:0 metrics:metrics views:views]];
        }
        
        if(i==attributions.count-1){
            [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[attribution]-verticalMargin-|" options:0 metrics:metrics views:views]];
        }
        
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-verticalMargin-[attribution]-verticalMargin-|" options:0 metrics:metrics views:views]];
        
        bottom = attribution;
    }
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

-(void)closeView:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
