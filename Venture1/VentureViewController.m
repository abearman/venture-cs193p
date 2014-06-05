// Gizz442@
// VentureViewController.m
//  Venture
//
//  Created by Amy Bearman on 4/11/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

/*

#import "VentureViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import <AFHTTPRequestOperationManager.h>
#import <GoogleMaps/GoogleMaps.h>
#import <pthread.h>
#import <QuartzCore/QuartzCore.h>
#import "RatingViewController.h"

@interface VentureViewController()

@property (weak, nonatomic) IBOutlet UILabel *appTitle;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeOfTransportation;
@property (weak, nonatomic) IBOutlet UISegmentedControl *activityType;

@property (weak, nonatomic) IBOutlet UILabel *activityName1;
@property (weak, nonatomic) IBOutlet UILabel *activityAddress1;
@property (weak, nonatomic) IBOutlet UILabel *activityJustification1;
@property (weak, nonatomic) IBOutlet UILabel *activityDistanceAway1;
@property (weak, nonatomic) IBOutlet UIImageView *activityYelpRating1;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSString *activityImgStr;
@property (weak, nonatomic) IBOutlet UIImageView *ventureBotImageView;

@property (strong, nonatomic) NSMutableArray *activities; // of VentureActivity

@property (strong, nonatomic) NSMutableDictionary *activitiesDict; // Keys: "Hungry", "Adventurous", "Bored"

@property (weak, nonatomic) IBOutlet UIView *activityView;

@end

@implementation VentureViewController {
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    CLGeocoder *geocoder;
    
    NSString *activityLat;
    NSString *activityLng;
    int indexActivitiesArray;
    
    NSUUID *udid;
    int userID;
    
    UIImageView *imageView;
}

-(void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Became active" object:nil];
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayRatingsView:)
                                                 name:@"Became active" object:nil];
}

-(void)displayRatingsView:(NSNotification*)_notification {
    [[self navigationController] popToRootViewControllerAnimated:YES];
    NSString *retrievedActivityTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"Saved Activity Title"];
    NSString *retrievedActivityImgURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"Saved Activity Image"];
    
    if (!(retrievedActivityTitle == nil || retrievedActivityImgURL == nil)) {
        [self performSegueWithIdentifier:@"Start Rating" sender:self];
    }
}

// Lazily intantiate the model
- (HomeModel *)model {
    if (!_model) _model = [[HomeModel alloc] init];
    return _model;
}

// Lazily instantiate the NSArray of VentureActivity's
- (NSMutableArray *)activities {
    if (!_activities) _activities = [[NSMutableArray alloc] init];
    return _activities;
}

// Lazily instantiate the NSMutableDictionary of VentureActivity's
- (NSMutableDictionary *)activitiesDict {
    if (!_activitiesDict) _activitiesDict = [[NSMutableDictionary alloc] init];
    return _activitiesDict;
}

-(void)viewDidUnload {
    [self unregisterForNotifications];
}

- (void) viewDidLoad {
    
    
    [[self navigationController] setNavigationBarHidden:YES];
    [self registerForNotifications];
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
    self.appTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient"]];
    self.appTitle.font = [UIFont fontWithName:@"Lobster" size:40];
    [self.appTitle sizeToFit];

    udid = [[UIDevice currentDevice] identifierForVendor];
    
    NSDictionary *parameters = @{@"deviceid": udid};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://grapevine.stanford.edu:8080/VentureBrain/Device" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = (NSDictionary *)(responseObject);
        userID = [[dict objectForKey:@"uid"] integerValue];
        
        //Loads first suggestion
        int indexOfTransport = self.modeOfTransportation.selectedSegmentIndex;
        int indexOfFeeling = self.activityType.selectedSegmentIndex;
        [self getNewActivity:indexOfTransport atFeeling:indexOfFeeling];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [super viewDidLoad];
    indexActivitiesArray = 0;
    
    [self.spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.spinner setColor:[UIColor colorWithWhite: 0.70 alpha:1]];
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    //Starts up location tracking
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    self.searchBar.delegate = self;
    
    self.spinner.hidesWhenStopped = YES;
    [self.spinner startAnimating];

    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeRight)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeUp)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipeLeft)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.activityView addGestureRecognizer:swipeRight];
    [self.activityView addGestureRecognizer:swipeUp];
    [self.activityView addGestureRecognizer:swipeLeft];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Start Rating"]){
        [self.activities removeAllObjects];
        indexActivitiesArray = 0;
        [imageView removeFromSuperview]; // Necessary?
        
        RatingViewController *rvc = [segue destinationViewController];
        rvc.userID = userID;
    }
}

- (IBAction)modeOfTransportChanged:(UISegmentedControl *)sender {
    int indexOfTransport = self.modeOfTransportation.selectedSegmentIndex;
    int indexOfFeeling = self.activityType.selectedSegmentIndex;
    [imageView removeFromSuperview];
    [self getNewActivity:indexOfTransport atFeeling:indexOfFeeling];
}

- (IBAction)typeOfActivityChanged:(UISegmentedControl *)sender {
    int indexOfTransport = self.modeOfTransportation.selectedSegmentIndex;
    int indexOfFeeling = self.activityType.selectedSegmentIndex;
    [imageView removeFromSuperview];
    [self getNewActivity:indexOfTransport atFeeling:indexOfFeeling];
}

-(void)getActivityAtIndex {
    //Retrieve existing element
    VentureActivity *activity = [self.activities objectAtIndex:indexActivitiesArray];
    self.activityName1.text = activity.title;
    self.activityAddress1.text = activity.address;
    self.activityJustification1.text = activity.justification;
    
    activityLat = activity.lat;
    activityLng = activity.lng;
    
    CLLocation *loc1 = currentLocation;
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:[activityLat doubleValue] longitude:[activityLng doubleValue]];
    
    double distance = [loc1 distanceFromLocation:loc2];
    distance /= 1000.0;
    self.activityDistanceAway1.text = [NSString stringWithFormat:@"%f km", distance];
    
    NSString *ImageURL = activity.imageURL;
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
    UIImage *image = [UIImage imageWithData:imageData];
    imageView = [[UIImageView alloc] initWithImage:image];
    
    double x = (self.view.frame.size.width / 2.0) - 75;
    double y = 100;
    [imageView setFrame:CGRectMake(x,y,150,150)];
    
    imageView.backgroundColor = [UIColor clearColor];
    imageView.layer.cornerRadius = 150 / 2;
    imageView.layer.masksToBounds = YES;
    [self.activityView addSubview: imageView];
    
    NSString *yelpURL = activity.yelpRatingImageURL;
    NSData *imageDataYelp = [NSData dataWithContentsOfURL:[NSURL URLWithString:yelpURL]];
    self.activityYelpRating1.image = [UIImage imageWithData:imageDataYelp];
}

-(void)respondToSwipeLeft {
    if (indexActivitiesArray > 0) {
        [imageView removeFromSuperview];
        NSLog(@"Swiped left");
        indexActivitiesArray--;
        NSLog(@"Index: %d", indexActivitiesArray);
        
        NSLog(@"Index: %d", indexActivitiesArray);
        [self getActivityAtIndex];
        self.savedActivity = [self.activities objectAtIndex:indexActivitiesArray];
    }
}

-(void)respondToSwipeRight {
    [imageView removeFromSuperview];
    NSLog(@"Swiped right");
    indexActivitiesArray++;
    NSLog(@"Index: %d", indexActivitiesArray);
    
    if (indexActivitiesArray <= [self.activities count] - 1) {
        [self getActivityAtIndex];
    } else {
        int indexOfTransport = self.modeOfTransportation.selectedSegmentIndex;
        int indexOfFeeling = self.activityType.selectedSegmentIndex;
        [self getNewActivity:indexOfTransport atFeeling:indexOfFeeling];
    }
}

-(void)respondToSwipeUp {
    [[NSUserDefaults standardUserDefaults] setObject:self.savedActivity.title forKey:@"Saved Activity Title"];
    [[NSUserDefaults standardUserDefaults] setObject:self.savedActivity.imageURL forKey:@"Saved Activity Image"];
    [[NSUserDefaults standardUserDefaults] setObject:self.savedActivity.ID forKey:@"Saved Activity ID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"%@", self.savedActivity.ID);
    
    NSString *destAddr;
    destAddr = [self.activityAddress1.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];

    NSString *modeOfTransport;
    int index = [self.modeOfTransportation selectedSegmentIndex];
    if (index == 0) {
        modeOfTransport = @"walking";
    } else if (index == 1) {
        modeOfTransport = @"biking";
    } else if (index == 2) {
        modeOfTransport = @"driving";
    } else if (index == 3) {
        modeOfTransport = @"transit";
    }
    
    NSString *url = [NSString stringWithFormat:@"comgooglemaps://?origin=%f,%f&daddr=%@&center=%@,%@&directionsmode=%@&zoom=10", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, destAddr, activityLat, activityLng, modeOfTransport];
    
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:url]];
    } else {
        NSLog(@"Can't use comgooglemaps://");
    }
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    currentLocation = newLocation;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [imageView removeFromSuperview];
    [self.searchBar resignFirstResponder];
    NSString *specifiedLoc = self.searchBar.text;
    
    [geocoder geocodeAddressString:specifiedLoc
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     if (!error) {
                         CLPlacemark *placemark = [placemarks firstObject];
                         currentLocation = placemark.location;
                         [locationManager stopUpdatingLocation];
                         NSLog(@"New loc: %f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
                         [self.activities removeAllObjects];
                         indexActivitiesArray = 0;
                         
                         int indexOfTransport = self.modeOfTransportation.selectedSegmentIndex;
                         int indexOfFeeling = self.activityType.selectedSegmentIndex;
                         [self getNewActivity:indexOfTransport atFeeling:indexOfFeeling];
                     } else {
                         NSLog(@"There was a forward geocoding error\n%@",
                               [error localizedDescription]);
                     }
                 }
     ];
}

-(void)getNewActivity:(int)indexOfTransport atFeeling:(int)indexOfFeeling {
    [self.spinner startAnimating];
    
    self.activityName1.text = @"";
    self.activityAddress1.text = @"";
    self.activityJustification1.text = @"";
    self.activityDistanceAway1.text = @"";
    self.activityImgStr = nil;
    self.activityYelpRating1.image = nil;
    
    [self.model downloadActivity:indexOfTransport atFeeling:indexOfFeeling withUser:userID atLatitude:currentLocation.coordinate.latitude atLongitude:currentLocation.coordinate.longitude withCallback:^
        (VentureActivity* activity) {
            
        [self.activities addObject:activity];
        self.savedActivity = activity;
            
        self.activityName1.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ self.activityName1.alpha = 1;}
                         completion:nil];
        self.activityName1.text = activity.title;
        
        self.activityAddress1.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ self.activityAddress1.alpha = 1;}
                         completion:nil];
        self.activityAddress1.text = activity.address;
        
        self.activityJustification1.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ self.activityJustification1.alpha = 1;}
                         completion:nil];
        self.activityJustification1.text = activity.justification;
        
        self.activityImgStr = activity.imageURL;
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.activityImgStr]];
        UIImage *image = [UIImage imageWithData:imageData];
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ imageView.alpha = 1;}
                         completion:nil];
        
        double x = (self.view.frame.size.width / 2.0) - 75;
        double y = 100;
        [imageView setFrame:CGRectMake(x,y,150,150)];
        
        imageView.backgroundColor = [UIColor clearColor];
        imageView.layer.cornerRadius = 150 / 2;
        imageView.layer.masksToBounds = YES;
        [self.activityView addSubview: imageView];
        
        self.activityYelpRating1.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ self.activityYelpRating1.alpha = 1;}
                         completion:nil];
        NSString *yelpURL = activity.yelpRatingImageURL;
        NSData *imageDataYelp = [NSData dataWithContentsOfURL:[NSURL URLWithString:yelpURL]];
        self.activityYelpRating1.image = [UIImage imageWithData:imageDataYelp];
        
        //Do google maps stuff to get time of travel and distance away
        activityLat = activity.lat;
        activityLng = activity.lng;
        
        CLLocation *loc1 = currentLocation;
        CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:[activityLat doubleValue] longitude:[activityLng doubleValue]];
        
        double distance = [loc1 distanceFromLocation:loc2];
        distance /= 1000.0;
        
        self.activityDistanceAway1.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ self.activityDistanceAway1.alpha = 1;}
                         completion:nil];
        self.activityDistanceAway1.text = [NSString stringWithFormat:@"%f km", distance];
        
        //stop spinner
        [self.spinner stopAnimating];
    }];
}

@end

*/