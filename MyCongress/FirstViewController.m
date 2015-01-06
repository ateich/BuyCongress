//
//  FirstViewController.m
//  MyCongress
//
//  Created by Andrew Teich on 12/11/14.
//  Copyright (c) 2014 Andrew Teich. All rights reserved.
//

#import "FirstViewController.h"
#import "SunlightFactory.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //TEST
    UITextView *name = [[UITextView alloc] init];
    [name setTranslatesAutoresizingMaskIntoConstraints:NO];
    [name setBackgroundColor:[UIColor blueColor]];
    name.text = @"TESTING";
    [self.view addSubview:name];
    
    //LEFT
    NSLayoutConstraint *nameLeftConstraint = [NSLayoutConstraint constraintWithItem:name attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    
    //RIGHT
    NSLayoutConstraint *nameRightConstraint = [NSLayoutConstraint constraintWithItem:name attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    
    //TOP
    NSLayoutConstraint *nameTopConstraint = [NSLayoutConstraint constraintWithItem:name attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    //BOTTOM
    NSLayoutConstraint *nameBottomConstraint = [NSLayoutConstraint constraintWithItem:name attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    [self.view addConstraint:nameLeftConstraint];
    [self.view addConstraint:nameRightConstraint];
    [self.view addConstraint:nameTopConstraint];
    [self.view addConstraint:nameBottomConstraint];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
