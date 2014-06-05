//
//  SubmitAdventureVC.h
//  Venture
//
//  Created by Amy Bearman on 5/22/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TrackAdventureVC : UIViewController

@property (strong, nonatomic) MKPointAnnotation *selectedAnnotation;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
