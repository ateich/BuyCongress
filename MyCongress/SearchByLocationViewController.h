//
//  SearchByLocationViewController.h
//  MyCongress
//
//  Created by Andrew Teich on 12/11/14.
//  Copyright (c) 2014 Andrew Teich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SearchByLocationViewController : UIViewController<UITextFieldDelegate, CLLocationManagerDelegate>

-(IBAction)showAttributions:(id)sender;

@end

