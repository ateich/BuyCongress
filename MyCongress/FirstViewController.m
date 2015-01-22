//
//  FirstViewController.m
//  MyCongress
//
//  Created by Andrew Teich on 12/11/14.
//  Copyright (c) 2014 Andrew Teich. All rights reserved.
//

#import "FirstViewController.h"
#import "SunlightFactory.h"
#import "SunlightFactory.h"
#import "TableViewController.h"

@interface FirstViewController (){
    UITextField *zipCodeField;
    SunlightFactory *sunlightAPI;
    #define NUMBERS_ONLY @"1234567890"
    #define CHARACTER_LIMIT 5
    CLLocationManager *locationManager;
    TableViewController *tableViewController;
}

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sunlightAPI = [[SunlightFactory alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    
    UIView *containerView = [[UIView alloc] init];
    [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:containerView];
    
    UIView *topSpacer = [[UIView alloc] init];
    [topSpacer setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:topSpacer];
    
    UIView *bottomSpacer = [[UIView alloc] init];
    [bottomSpacer setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:bottomSpacer];
    
    zipCodeField = [[UITextField alloc] init];
    [zipCodeField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [zipCodeField setDelegate:self];
    [zipCodeField setPlaceholder:@"Enter your Zip Code Here"];
    [zipCodeField setTextAlignment:NSTextAlignmentCenter];
    [zipCodeField setKeyboardType:UIKeyboardTypeNumberPad];
    [containerView addSubview:zipCodeField];
    
    UIButton *searchByZipCode = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [searchByZipCode setTranslatesAutoresizingMaskIntoConstraints:NO];
    [searchByZipCode setTitle:@"Search by Zip Code" forState:UIControlStateNormal];
    [searchByZipCode addTarget:self action:@selector(searchForPoliticiansByZipCode:) forControlEvents:UIControlEventTouchDown];
    [containerView addSubview:searchByZipCode];
    
    UILabel *or = [[UILabel alloc] init];
    [or setTranslatesAutoresizingMaskIntoConstraints:NO];
    [or setText:@"or"];
    [or setTextAlignment:NSTextAlignmentCenter];
    [containerView addSubview:or];
    
    UIButton *searchByCurrentLocation = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [searchByCurrentLocation setTranslatesAutoresizingMaskIntoConstraints:NO];
    [searchByCurrentLocation setTitle:@"Use My Current Location" forState:UIControlStateNormal];
    [searchByCurrentLocation addTarget:self action:@selector(searchForPoliticiansByLocation:) forControlEvents:UIControlEventTouchDown];
    [containerView addSubview:searchByCurrentLocation];
    
    //AUTOLAYOUT
    NSDictionary *metrics = @{@"tabBarHeight":[NSNumber numberWithDouble:self.tabBarController.tabBar.frame.size.height]};
    NSDictionary *views = NSDictionaryOfVariableBindings(containerView, topSpacer, bottomSpacer, zipCodeField, searchByZipCode, or, searchByCurrentLocation);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[topSpacer]-[containerView]-[bottomSpacer(==topSpacer)]-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[containerView]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[topSpacer]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[bottomSpacer]-|" options:0 metrics:nil views:views]];
    
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[zipCodeField]-[searchByZipCode]-[or]-[searchByCurrentLocation]-tabBarHeight-|" options:0 metrics:metrics views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[zipCodeField]-|" options:0 metrics:nil views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[searchByZipCode]-|" options:0 metrics:nil views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[or]-|" options:0 metrics:nil views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[searchByCurrentLocation]-|" options:0 metrics:nil views:views]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticiansForZip:) name:@"SunlightFactoryDidReceivePoliticiansForZipCodeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticiansForLocation:) name:@"SunlightFactoryDidReceivePoliticiansForLatitudeAndLongitudeNotification" object:nil];
}

- (void)searchForPoliticiansByZipCode:(UIButton *)sender{
    [sunlightAPI getLawmakersByZipCode:zipCodeField.text];
}

- (void)searchForPoliticiansByLocation:(UIButton *)sender{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
}

- (void)didReceivePoliticiansForZip:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSMutableArray *politicianData = [[userInfo objectForKey:@"getLawmakersByZipCode"] objectForKey:@"results"];
    [self openTableOfPoliticians:politicianData];
}

- (void)didReceivePoliticiansForLocation:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSMutableArray *politicianData = [[userInfo objectForKey:@"getLawmakersByLatitudeAndLongitude"] objectForKey:@"results"];
    [self openTableOfPoliticians:politicianData];
}

-(void)openTableOfPoliticians:(NSMutableArray*)data{
    tableViewController = [[TableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:tableViewController animated:YES];
    
    [tableViewController updateTableViewWithNewData:[tableViewController createPoliticiansFromDataArray:data]];
    [tableViewController updateTableViewWithNewData:[tableViewController createPoliticiansFromDataArray:data]];
}

//Limit text field length to 5 numbers, no letters (Zip Code)
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS_ONLY] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return (([string isEqualToString:filtered])&&(newLength <= CHARACTER_LIMIT));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Hide keyboard
-(void)viewWillDisappear:(BOOL)animated{
    if ([zipCodeField isFirstResponder]) {
        [zipCodeField resignFirstResponder];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([zipCodeField isFirstResponder] && [touch view] != zipCodeField) {
        [zipCodeField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSString *longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        [locationManager stopUpdatingLocation];
        [sunlightAPI getLawmakersByLatitude:latitude andLongitude:longitude];
    }
}

@end
