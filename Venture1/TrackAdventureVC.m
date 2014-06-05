//
//  SubmitAdventureVC.m
//  Venture
//
//  Created by Amy Bearman on 5/22/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "TrackAdventureVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "CreateAdventureTVC.h"

#define METERS_PER_MILE 1609.344
#define DURATION_LONG_PRESS 0.5

@interface TrackAdventureVC () <CLLocationManagerDelegate, MKMapViewDelegate>

@end

@implementation TrackAdventureVC

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationBar];
    [self setUpGestureRecognizersForMap];
    self.mapView.delegate = self;
    
    [self.mapView.userLocation addObserver:self forKeyPath:@"location" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}

- (void) mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    @try {
        [self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
    } @catch(id anException) {
        // Do nothing
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([self.mapView showsUserLocation]) {
        MKCoordinateRegion region;
        region.center = self.mapView.userLocation.coordinate;
        
        MKCoordinateSpan span;
        span.latitudeDelta  = 1; // Change these values to change the zoom
        span.longitudeDelta = 1;
        region.span = span;
        
        [self.mapView setRegion:region animated:YES];
    }
}

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

- (void) setUpGestureRecognizersForMap {
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = DURATION_LONG_PRESS; //user needs to press for half a second
    [self.mapView addGestureRecognizer:lpgr];
}

- (void) handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = touchMapCoordinate;
    annotation.title = @"Point!";
    
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
    self.selectedAnnotation = annotation;
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *pinView = nil;
    if (annotation != mapView.userLocation) {
        static NSString *defaultPin = @"pinID";
        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPin];
        if (pinView == nil) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPin];
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.canShowCallout = YES;
            pinView.animatesDrop = YES;
            pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
    } else {
        [mapView.userLocation setTitle:@"You are here!"];
    }
    return pinView;
}

- (void)mapView:(MKMapView *)_mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"Selected annotation view!");
    self.selectedAnnotation = view.annotation;
    [self performSegueWithIdentifier:@"Selected Annotation" sender:self.mapView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Selected Annotation"]) {
        CreateAdventureTVC *catvc = segue.destinationViewController;
        catvc.annotation = self.selectedAnnotation;
    }
}

@end




