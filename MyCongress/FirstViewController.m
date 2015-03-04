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
#import "ColorScheme.h"
#import "AttributionViewController.h"

@interface FirstViewController (){
    
    #define NUMBERS_ONLY @"1234567890"
    #define CHARACTER_LIMIT 5
    
    UITextField *zipCodeField;
    SunlightFactory *sunlightAPI;
    CLLocationManager *locationManager;
    TableViewController *tableViewController;
    
    UIButton *zipCodeSearchButton;
    UIButton *locationSearchButton;
    
    UIActivityIndicatorView *loading;
    AttributionViewController *attributions;
}

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sunlightAPI = [[SunlightFactory alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    attributions = [[AttributionViewController alloc] init];
    
    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.backgroundColor = [ColorScheme backgroundColor];
    [self.view addSubview:containerView];
    
    UILabel *instructions = [[UILabel alloc] init];
    instructions.translatesAutoresizingMaskIntoConstraints = NO;
    instructions.textAlignment = NSTextAlignmentCenter;
    instructions.font = [UIFont boldSystemFontOfSize:16.0];
    instructions.textColor = [ColorScheme headerColor];
    instructions.numberOfLines = 0;
    instructions.text = @"Search representatives by zip code";
    instructions.text = [instructions.text capitalizedString];
    [containerView addSubview:instructions];
    
    UIView *zipCard = [[UIView alloc] init];
    zipCard.translatesAutoresizingMaskIntoConstraints = NO;
    zipCard.backgroundColor = [ColorScheme cardColor];
    [containerView addSubview:zipCard];
    
    UIView *locationCard = [[UIView alloc] init];
    locationCard.translatesAutoresizingMaskIntoConstraints = NO;
    locationCard.backgroundColor = [ColorScheme cardColor];
    [containerView addSubview:locationCard];
    
    zipCodeField = [[UITextField alloc] init];
    zipCodeField.translatesAutoresizingMaskIntoConstraints = NO;
    zipCodeField.font = [UIFont systemFontOfSize:15.0];
    zipCodeField.textColor = [ColorScheme headerColor];
    zipCodeField.delegate = self;
    zipCodeField.placeholder = @"Tap Here To Enter Your Zip Code";
    zipCodeField.textAlignment = NSTextAlignmentCenter;
    zipCodeField.keyboardType = UIKeyboardTypeNumberPad;
    zipCodeField.backgroundColor = [ColorScheme backgroundColor];
    [zipCard addSubview:zipCodeField];
    
    UIButton *searchByZipCode = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    searchByZipCode.translatesAutoresizingMaskIntoConstraints = NO;
    [searchByZipCode setBackgroundImage:[ColorScheme imageWithColor:[ColorScheme subTextColor]]forState:UIControlStateNormal];
    [searchByZipCode setBackgroundImage:[ColorScheme imageWithColor:[ColorScheme selectedButtonColor]]forState:UIControlStateHighlighted];
    [searchByZipCode setBackgroundImage:[ColorScheme imageWithColor:[ColorScheme selectedButtonColor]]forState:UIControlStateSelected];
    [searchByZipCode setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [searchByZipCode setTitle:@"Search By Zip Code" forState:UIControlStateNormal];
    [searchByZipCode addTarget:self action:@selector(searchForPoliticiansByZipCode:) forControlEvents:UIControlEventTouchUpInside];
    [zipCard addSubview:searchByZipCode];
    zipCodeSearchButton = searchByZipCode;
    
    UILabel *or = [[UILabel alloc] init];
    or.translatesAutoresizingMaskIntoConstraints = NO;
    or.font = [UIFont boldSystemFontOfSize:16.0];
    or.textColor = [ColorScheme headerColor];
    or.text = @"or use your current location".capitalizedString;
    or.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:or];
    
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.translatesAutoresizingMaskIntoConstraints = NO;
    [locationButton setBackgroundImage:[ColorScheme imageWithColor:[ColorScheme subTextColor]]forState:UIControlStateNormal];
    [locationButton setBackgroundImage:[ColorScheme imageWithColor:[ColorScheme selectedButtonColor]]forState:UIControlStateHighlighted];
    [locationButton setBackgroundImage:[ColorScheme imageWithColor:[ColorScheme selectedButtonColor]]forState:UIControlStateSelected];
    [locationButton addTarget:self action:@selector(searchForPoliticiansByLocation:) forControlEvents:UIControlEventTouchUpInside];
    [locationCard addSubview:locationButton];
    
    UIButton *locationIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    locationIcon.translatesAutoresizingMaskIntoConstraints = NO;
    locationIcon.userInteractionEnabled = NO;
    locationIcon.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    
    UIImage *locationImage = [[UIImage imageNamed:@"location.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [locationIcon setImage:locationImage forState:UIControlStateNormal];
    locationIcon.tintColor = [UIColor whiteColor];
    [locationButton addSubview:locationIcon];
    
    UIButton *searchByCurrentLocation = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    searchByCurrentLocation.userInteractionEnabled = NO;
    searchByCurrentLocation.translatesAutoresizingMaskIntoConstraints = NO;
    searchByCurrentLocation.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [searchByCurrentLocation setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [searchByCurrentLocation setTitle:@"Search By Current Location" forState:UIControlStateNormal];
    [locationButton addSubview:searchByCurrentLocation];
    locationSearchButton = locationButton;
    
    
    //AUTOLAYOUT
    NSNumber *leftMargin = @15;
    NSNumber *halfMargin = @([leftMargin intValue]/2);
    NSNumber *quarterMargin = @([halfMargin intValue]/2);
    NSDictionary *metrics = @{@"tabBarHeight":[NSNumber numberWithDouble:self.tabBarController.tabBar.frame.size.height], @"leftMargin":leftMargin, @"topMargin":halfMargin, @"largeTopMargin":halfMargin, @"sideMargin":@10, @"quarterMargin":quarterMargin};
    
    //Zip Code Card Spacers
    UIView *spacer1 = [[UIView alloc] init];
    UIView *spacer2 = [[UIView alloc] init];
    UIView *spacer3 = [[UIView alloc] init];
    
    spacer1.translatesAutoresizingMaskIntoConstraints = NO;
    spacer2.translatesAutoresizingMaskIntoConstraints = NO;
    spacer3.translatesAutoresizingMaskIntoConstraints = NO;
    
    [zipCard addSubview:spacer1];
    [zipCard addSubview:spacer2];
    [zipCard addSubview:spacer3];
    
    //Location Spacers
    UIView *spacer4 = [[UIView alloc] init];
    UIView *spacer5 = [[UIView alloc] init];
    
    spacer4.translatesAutoresizingMaskIntoConstraints = NO;
    spacer5.translatesAutoresizingMaskIntoConstraints = NO;
    
    [locationButton addSubview:spacer4];
    [locationButton addSubview:spacer5];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(containerView, instructions, zipCard, locationCard, zipCodeField, searchByZipCode, or, locationIcon, searchByCurrentLocation, spacer1, spacer2, spacer3, spacer4, spacer5, locationButton);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[containerView]-0-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[containerView]-0-|" options:0 metrics:nil views:views]];
   
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(<=leftMargin,>=10@400,>=0)-[instructions(<=50)]-(<=leftMargin,>=10@400,>=0)-[zipCard(==locationCard)]-(<=leftMargin,>=10@250,>=5)-[or(==25@400)]-(<=leftMargin,>=10@250,>=5)-[locationCard]-(<=leftMargin,>=0)-|" options:0 metrics:metrics views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[zipCard]-leftMargin-|" options:0 metrics:metrics views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[locationCard]-leftMargin-|" options:0 metrics:metrics views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[instructions]-leftMargin-|" options:0 metrics:metrics views:views]];
    
    
    [zipCard addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[spacer1(==spacer2,==spacer3)]-[zipCodeField(==searchByZipCode)]-[spacer2]-[searchByZipCode(>=50@800)]-[spacer3]-|" options:0 metrics:metrics views:views]];
    [zipCard addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[zipCodeField]-leftMargin-|" options:0 metrics:metrics views:views]];
    [zipCard addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[searchByZipCode]-leftMargin-|" options:0 metrics:metrics views:views]];
    
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[or]-|" options:0 metrics:nil views:views]];
    
    [locationCard addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-leftMargin-[locationButton]-(leftMargin@400)-|" options:0 metrics:metrics views:views]];
    [locationCard addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[locationButton]-leftMargin-|" options:0 metrics:metrics views:views]];
    
    [locationButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[spacer4(==spacer5)]-[locationIcon]-0-[searchByCurrentLocation]-[spacer5]-|" options:0 metrics:metrics views:views]];
    [locationButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[searchByCurrentLocation]-|" options:0 metrics:nil views:views]];
    [locationButton addConstraint:[NSLayoutConstraint constraintWithItem:locationIcon attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:locationIcon attribute:NSLayoutAttributeHeight multiplier:0.70731707 constant:0.0f]];
    [locationButton addConstraint:[NSLayoutConstraint constraintWithItem:locationIcon attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:locationButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0f]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticiansForZip:) name:@"SunlightFactoryDidReceiveGetLawmakersByZipCodeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePoliticiansForLocation:) name:@"SunlightFactoryDidReceiveGetLawmakersByLatitudeAndLongitudeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionTimedOut:) name:@"SunlightFactoryDidReceiveConnectionTimedOutForSearchNotification" object:nil];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //Loading indicator
    loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loading.color = [ColorScheme headerColor];
    loading.translatesAutoresizingMaskIntoConstraints = NO;
    loading.hidesWhenStopped = YES;
    [self.view addSubview:loading];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loading attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loading attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

- (void)connectionTimedOut:(NSNotification*)notification{
    NSString *title = @"Cannot gather data";
    NSString *message = @"Please check your internet connection and try again.";
    
    if ([notification userInfo]) {
        title = notification.userInfo[@"title"];
        message = notification.userInfo[@"message"];
    }
    
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:title  message:message  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self.view.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    
    [loading stopAnimating];
    zipCodeSearchButton.enabled = YES;
    locationSearchButton.enabled = YES;
    
    zipCodeSearchButton.userInteractionEnabled = YES;
    locationSearchButton.userInteractionEnabled = YES;
    
    [locationManager stopUpdatingLocation];
    
    NSLog(@"lsb: %i", locationSearchButton.enabled);
}

- (void)searchForPoliticiansByZipCode:(UIButton *)sender{
    sender.userInteractionEnabled = NO;
    
    if(zipCodeField.text.length != 5){
        UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Incorrect Zip Code"  message:@"Please enter a 5 digit zip code."  preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        sender.userInteractionEnabled = YES;
    } else {
        [loading startAnimating];
        [sunlightAPI getLawmakersByZipCode:zipCodeField.text];
    }
}

- (void)searchForPoliticiansByLocation:(UIButton *)sender{
    sender.userInteractionEnabled = NO;
    [loading startAnimating];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    locationManager.distanceFilter = 500;
    
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
}

- (void)didReceivePoliticiansForZip:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSMutableArray *politicianData = userInfo[@"results"][@"results"];
    [self openTableOfPoliticians:politicianData];
    zipCodeSearchButton.userInteractionEnabled = YES;
    [loading stopAnimating];
}

- (void)didReceivePoliticiansForLocation:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSMutableArray *politicianData = userInfo[@"results"][@"results"];
    [self openTableOfPoliticians:politicianData];
    locationSearchButton.userInteractionEnabled = YES;
    [loading stopAnimating];
}

-(void)openTableOfPoliticians:(NSMutableArray*)data{
    tableViewController = [[TableViewController alloc] initWithStyle:UITableViewStylePlain];
    [tableViewController hideSectionIndexBar:YES];
    [self.navigationController pushViewController:tableViewController animated:YES];
    
    [tableViewController updateTableViewWithNewData:[tableViewController createPoliticiansFromDataArray:data]];
}

//Limit text field length to 5 numbers, no letters (Zip Code)
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = textField.text.length + string.length - range.length;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:NUMBERS_ONLY].invertedSet;
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return (([string isEqualToString:filtered])&&(newLength <= CHARACTER_LIMIT));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Hide keyboard
-(void)viewWillDisappear:(BOOL)animated{
    if (zipCodeField.isFirstResponder) {
        [zipCodeField resignFirstResponder];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if (zipCodeField.isFirstResponder && touch.view != zipCodeField) {
        [zipCodeField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError: %@", error);
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Location Unavailable"  message:@"We are unable to get your current location. Please seach by zip code to continue."  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    [locationManager stopUpdatingLocation];
    locationSearchButton.userInteractionEnabled = YES;
    [loading stopAnimating];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSString *longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        [locationManager stopUpdatingLocation];
        [sunlightAPI getLawmakersByLatitude:latitude andLongitude:longitude];
    }
}

- (void) dealloc {
    //Stop listening for changes to Politician Data
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SunlightFactoryDidReceiveGetLawmakersByZipCodeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SunlightFactoryDidReceiveGetLawmakersByLatitudeAndLongitudeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SunlightFactoryDidReceiveConnectionTimedOutForSearchNotification" object:nil];
}

-(IBAction)showAttributions:(id)sender{
    [self presentViewController:attributions animated:YES completion:nil];
}

@end
