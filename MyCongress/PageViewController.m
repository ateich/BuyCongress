//
//  PageViewController.m
//  MyCongress
//
//  Created by HackReactor on 2/26/15.
//  Copyright (c) 2015 HackReactor. All rights reserved.
//

#import "PageViewController.h"
#import "ColorScheme.h"

@interface PageViewController ()

@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *instructionLabel = [[UILabel alloc] init];
    instructionLabel.text = self.instruction;
    [instructionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [instructionLabel setTextColor:[ColorScheme subTextColor]];
    [instructionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:instructionLabel];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:imageView];
    
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Instruction%li.png", (long)self.index]];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(instructionLabel, imageView);
    NSNumber *statusBarHeight = [NSNumber numberWithDouble:[UIApplication sharedApplication].statusBarFrame.size.height];
    NSNumber *verticalMargin = [NSNumber numberWithInt:10];
    NSNumber *topMargin = [NSNumber numberWithDouble:[statusBarHeight doubleValue] + [verticalMargin doubleValue]];
    NSDictionary *metrics = @{@"statusBarHeight": statusBarHeight, @"verticalMargin":verticalMargin, @"topMargin":topMargin};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topMargin-[instructionLabel]-[imageView]-verticalMargin-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[imageView]-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[instructionLabel]-|" options:0 metrics:metrics views:views]];
    
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
