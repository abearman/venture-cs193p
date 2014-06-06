//
//  SuggestionVC.m
//  Venture
//
//  Created by Amy Bearman on 5/22/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "SuggestionVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import <pthread.h>
#import <QuartzCore/QuartzCore.h>
#import "RatingViewController.h"
#import "VentureLocationTracker.h"
#import "VentureServerLayer.h"

@interface SuggestionVC() <UISearchBarDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>
{
    CGPoint slidingViewHome;
    CGPoint cachedTouchLocation;
}

/* Model */
@property (nonatomic) NSInteger modeOfTransportation;
@property (nonatomic) NSInteger activityType;
@property (nonatomic) VentureLocationTracker *locationTracker;
@property (nonatomic) VentureServerLayer *serverLayer;
@property (nonatomic) NSMutableDictionary *currentAdventure;

/* UI Outlets */
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *transportIcon;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIScrollView *activityView;

@property (weak, nonatomic) IBOutlet UILabel *activityName;
@property (weak, nonatomic) IBOutlet UILabel *activityAddress;
@property (weak, nonatomic) IBOutlet UILabel *activityDistanceAway;
@property (weak, nonatomic) IBOutlet UIImageView *activityYelpRating;
@property (weak, nonatomic) IBOutlet UIScrollView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *activityJustification;
@property (weak, nonatomic) IBOutlet UIImageView *ventureBotImageView;
@property (weak, nonatomic) IBOutlet UIView *dragView;

@property (weak, nonatomic) IBOutlet UIView *leftBumper;
@property (weak, nonatomic) IBOutlet UIView *rightBumper;
@property (weak, nonatomic) IBOutlet UIView *topBumper;

@property (weak, nonatomic) IBOutlet UILabel *rating1;
@property (weak, nonatomic) IBOutlet UILabel *rating2;
@property (weak, nonatomic) IBOutlet UILabel *rating3;

@end

#define EDGE_OFFSET 600

@implementation SuggestionVC

- (void) viewDidLoad {
    [super viewDidLoad];
    self.activityView.userInteractionEnabled = YES;
    
    self.locationTracker = [[VentureLocationTracker alloc] init];
    self.serverLayer = [[VentureServerLayer alloc] initWithLocationTracker:self.locationTracker];
    
    self.modeOfTransportation = 2;
    self.activityType = 0;
    
    [self setUpNavigationBar];
    [self setUpSearchBar];
    
    slidingViewHome = self.dragView.center;
    slidingViewHome.y -= 65;
    
    [self.leftBumper setAlpha:0];
    [self.rightBumper setAlpha:0];
    [self.topBumper setAlpha:0];
    
    [self.spinner startAnimating];
    [self.locationTracker setCallbackForFirstLocation:^{
        [self getNewActivity:self.modeOfTransportation atFeeling:self.activityType callback:^{}];
    }];
}

/*** NAVIGATION BAR AND SEARCH BAR ***/

- (void) setUpNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"purple-gradient"] forBarMetrics:UIBarMetricsDefault];
    CGRect frame = CGRectMake(0, 0, 400, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Lobster" size:40];
    label.textColor = [UIColor whiteColor];
    label.text = @"Venture";
    label.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = label;
}

- (void) setUpSearchBar {
    self.searchBar.hidden = YES;
    [self.searchBar setShowsCancelButton:YES animated:YES];
    self.searchBar.delegate = self;
}

- (IBAction)searchButtonClicked:(UIBarButtonItem *)sender {
    self.searchBar.hidden = NO;
    [self.searchBar becomeFirstResponder];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    self.searchBar.hidden = YES;
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *specifiedLoc = self.searchBar.text;
    
    [self.locationTracker setLocationToAddress:specifiedLoc];
    
    [self.searchBar resignFirstResponder];
    self.searchBar.hidden = YES;
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    CGFloat bumperWidth = 150;
    
    if ([recognizer numberOfTouches] > 0) {
        CGPoint touchLocation = [recognizer locationOfTouch:0 inView:self.view];
        
        [self.leftBumper setAlpha:1 - (touchLocation.x / bumperWidth)];
        [self.rightBumper setAlpha:1 - (([UIScreen mainScreen].bounds.size.width -
                                         touchLocation.x) / bumperWidth)];
        [self.topBumper setAlpha:1 - ((touchLocation.y-15) / bumperWidth)];
        
        cachedTouchLocation = touchLocation;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self.view];
        
        [self.leftBumper setAlpha:0];
        [self.rightBumper setAlpha:0];
        [self.topBumper setAlpha:0];
        
        int edgeOffset = 600;
        int velocityTrigger = 100;
        
        CGPoint touchLocation = cachedTouchLocation;
        if ((touchLocation.x < bumperWidth/2) || (velocity.x < -velocityTrigger)) {
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 recognizer.view.center = CGPointMake(-edgeOffset,slidingViewHome.y);
                             } completion:^(BOOL finished) {
                                 [self respondToSwipeRight];
                             }];
        }
        else if ((touchLocation.x > [[UIScreen mainScreen] bounds].size.width - (bumperWidth/2)) || (velocity.x > velocityTrigger)) {
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 recognizer.view.center = CGPointMake(edgeOffset,slidingViewHome.y);
                             } completion:^(BOOL finished) {
                                 [self respondToSwipeLeft];
                             }];
        }
        else if ((touchLocation.y < 15 + (bumperWidth/2)) || (velocity.y < -velocityTrigger)) {
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 recognizer.view.center = CGPointMake(slidingViewHome.x,-300);
                             } completion:^(BOOL finished) {
                                 [self respondToSwipeUp];
                                 [self animatedSuggestionReset];
                             }];
        }
        else {
            [self animatedSuggestionReset];
        }
        
    }
}

- (void)animatedSuggestionReset {
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.dragView.center = slidingViewHome;
                     } completion:^(BOOL finished) {
                         // Don't do anything, since we're just resetting
                     }];
}

/*** MODE OF TRANSPORT ***/

- (IBAction)modeOfTransportButtonClicked:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Walk", @"Bike", @"Drive", @"Public Transport", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"You have pressed the %@ button", [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (buttonIndex < 4) {
        self.modeOfTransportation = buttonIndex;
        if (self.modeOfTransportation == 0) {         // Walking
            self.transportIcon.image = [UIImage imageNamed:@"walk"];
        } else if (self.modeOfTransportation == 1) {  // Biking
            self.transportIcon.image = [UIImage imageNamed:@"bicycle"];
        } else if (self.modeOfTransportation == 2) {  // Driving
            self.transportIcon.image = [UIImage imageNamed:@"drive"];
        } else {                                      // Public transport
            self.transportIcon.image = [UIImage imageNamed:@"bus"];
        }
    }
}

-(void)getNewActivity:(int)indexOfTransport atFeeling:(int)indexOfFeeling callback:(void (^)())callback {
    [self.spinner startAnimating];
    NSLog(@"Getting adventure from %@",self.serverLayer);
    [self.serverLayer getNewAdventureSuggestion:^(NSMutableDictionary *suggestion) {
        [self.spinner stopAnimating];
        NSLog(@"Got adventure");
        self.currentAdventure = suggestion;
        callback();
    }];
}

-(void)updateImageView:(NSArray*)images {
    // Clear all the old images out
    for (UIView *view in self.imageView.subviews) {
        [view removeFromSuperview];
    }
    
    // Add images for all the pictures in the cache
    int x = 0;
    for (UIImage *image in images) {
        UIImageView *picture = [[UIImageView alloc] initWithImage:image];
        picture.frame = CGRectOffset(picture.frame, x, 0);
        x += picture.frame.size.width;
        self.imageView.contentSize = CGSizeMake(x,self.imageView.contentSize.height);
        [self.imageView addSubview:picture];
    }
}

- (void)setCurrentAdventure:(NSMutableDictionary *)currentAdventure {
    self->_currentAdventure = currentAdventure;
    self.activityName.text = [currentAdventure objectForKey:@"title"];
    NSString* lat = [currentAdventure objectForKey:@"latitude"];
    NSString* lng = [currentAdventure objectForKey:@"longitude"];
    NSString* address = [currentAdventure objectForKey:@"address"];
    if (address == nil && lat != nil && lng != nil) {
        [self.locationTracker reverseGeocodeLat:lat lng:lng callback:^(NSString *foundAddress) {
            self.activityAddress.text = foundAddress;
        }];
    }
    else if (address != nil) {
        self.activityAddress.text = address;
    }
    
    if (lat == nil && lng == nil && address != nil) {
        [self.locationTracker geocode:address callback:^(double latDouble, double lngDouble) {
            CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:latDouble longitude:lngDouble];
            double distance = [self.locationTracker.currentLocation distanceFromLocation:loc2];
            distance /= 1000.0;
            self.activityDistanceAway.text = [NSString stringWithFormat:@"%f km", distance];
        }];
    }
    else if (lat != nil && lng != nil) {
        NSLog(@"Doing lat and lng using current values");
        CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
        
        double distance = [self.locationTracker.currentLocation distanceFromLocation:loc2];
        distance /= 1000.0;
        self.activityDistanceAway.text = [NSString stringWithFormat:@"%f km", distance];
    }
    
    // Get ratings
    
    self.rating1.alpha = 0;
    self.rating2.alpha = 0;
    self.rating3.alpha = 0;
    
    int ratingNumber = 0;
    
    NSArray *metadataSources = [currentAdventure objectForKey:@"metadata"];
    for (NSDictionary *metadataSource in metadataSources) {
        NSString *source = [metadataSource objectForKey:@"source"];
        NSString *rating = @"";
        if ([source isEqualToString:@"urbanspoon.com"]) {
            rating = [NSString stringWithFormat:@"Urbanspoon %@/100 from %@ reviews",[metadataSource objectForKey:@"urbanspoon_rating"],[metadataSource objectForKey:@"urbanspoon_votes"]];
        }
        if ([source isEqualToString:@"opentable.com"]) {
            rating = [NSString stringWithFormat:@"OpenTable %@/5 from %@ reviews",[metadataSource objectForKey:@"opentable_rating"],[metadataSource objectForKey:@"opentable_ratings_count"]];
        }
        if ([source isEqualToString:@"yelp.com"]) {
            rating = [NSString stringWithFormat:@"Yelp %@/5 from %@ reviews",[metadataSource objectForKey:@"yelp_rating"],[metadataSource objectForKey:@"yelp_review_count"]];
        }
        if (ratingNumber == 0) {
            self.rating1.alpha = 1;
            self.rating1.text = rating;
        }
        else if (ratingNumber == 1) {
            self.rating2.alpha = 1;
            self.rating2.text = rating;
        }
        else if (ratingNumber == 2) {
            self.rating3.alpha = 1;
            self.rating3.text = rating;
        }
        ratingNumber++;
    }
    
    // Check if we've already downloaded the images for this guy in the past
    
    if (![[currentAdventure allKeys] containsObject:@"image_cache"]) {
        
        // Figure out a list of images to download
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        
        NSArray *metadataSources = [currentAdventure objectForKey:@"metadata"];
        for (NSDictionary *metadataSource in metadataSources) {
            NSString *source = [metadataSource objectForKey:@"source"];
            if ([source isEqualToString:@"urbanspoon.com"]) {
                if ([[metadataSource objectForKey:@"urbanspoon_images"] isKindOfClass:[NSArray class]])
                    [images addObjectsFromArray:[metadataSource objectForKey:@"urbanspoon_images"]];
                else if ([[metadataSource objectForKey:@"urbanspoon_images"] isKindOfClass:[NSString class]])
                    [images addObject:[metadataSource objectForKey:@"urbanspoon_images"]];
            }
            if ([source isEqualToString:@"opentable.com"]) {
                if ([[metadataSource objectForKey:@"opentable_image"] isKindOfClass:[NSString class]])
                    [images addObject:[metadataSource objectForKey:@"opentable_image"]];
            }
        }
        
        // Setup the image cache to receive images
        
        [currentAdventure setValue:[[NSMutableArray alloc] init] forKey:@"image_cache"];
        
        // Download all the images asynchronously
        
        for (NSString *imageURL in images) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            
            [[session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                if (!error) {
                    NSData *imageData = [NSData dataWithContentsOfURL:location];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[currentAdventure objectForKey:@"image_cache"] addObject:[UIImage imageWithData:imageData]];
                        if ([self.activityName.text isEqualToString:[currentAdventure objectForKey:@"title"]]) {
                            [self updateImageView:[currentAdventure objectForKey:@"image_cache"]];
                        }
                    });
                }
            }] resume];
        }
    }
    else {
        [self updateImageView:[currentAdventure objectForKey:@"image_cache"]];
    }
}

-(void)respondToSwipeLeft {
    if (self.currentAdventure != NULL && [self.serverLayer getPreviousCachedAdventureOrNull:self.currentAdventure] != NULL) {
        self.dragView.center = CGPointMake(-EDGE_OFFSET,slidingViewHome.y);
        self.currentAdventure = [self.serverLayer getPreviousCachedAdventureOrNull:self.currentAdventure];
    }
    [self animatedSuggestionReset];
}

-(void)respondToSwipeRight {
    self.dragView.center = CGPointMake(EDGE_OFFSET,slidingViewHome.y);
    if (self.currentAdventure != NULL && [self.serverLayer getNextCachedAdventureOrNull:self.currentAdventure] != NULL) {
        self.currentAdventure = [self.serverLayer getNextCachedAdventureOrNull:self.currentAdventure];
        [self animatedSuggestionReset];
    }
    else {
        [self getNewActivity:self.modeOfTransportation atFeeling:self.activityType callback:^{
            [self animatedSuggestionReset];
        }];
    }
}

-(void)respondToSwipeUp {
    /*[[NSUserDefaults standardUserDefaults] setObject:self.savedActivity.title forKey:@"Saved Activity Title"];
     [[NSUserDefaults standardUserDefaults] setObject:self.savedActivity.imageURL forKey:@"Saved Activity Image"];
     [[NSUserDefaults standardUserDefaults] setObject:self.savedActivity.ID forKey:@"Saved Activity ID"];
     [[NSUserDefaults standardUserDefaults] synchronize];
     
     NSLog(@"%@", self.savedActivity.ID);*/
    
    NSString *destAddr;
    destAddr = [self.activityAddress.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSString *modeOfTransport;
    int index = self.modeOfTransportation;
    if (index == 0) {
        modeOfTransport = @"walking";
    } else if (index == 1) {
        modeOfTransport = @"biking";
    } else if (index == 2) {
        modeOfTransport = @"driving";
    } else if (index == 3) {
        modeOfTransport = @"transit";
    }
    
    NSString *lat = [self.currentAdventure objectForKey:@"lat"];
    NSString *lng = [self.currentAdventure objectForKey:@"lng"];
    
    NSString *url = [NSString stringWithFormat:@"comgooglemaps://?origin=%@,%@&daddr=%@&center=%@,%@&directionsmode=%@&zoom=10", self.locationTracker.lat, self.locationTracker.lng, destAddr, lat, lng, modeOfTransport];
    
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:url]];
    } else {
        NSLog(@"Can't use comgooglemaps://");
    }
}

@end





