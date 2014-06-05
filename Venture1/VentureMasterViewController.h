//
//  VentureMasterViewController.h
//  Venture1
//
//  Created by Amy Bearman on 5/31/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VentureDetailViewController;

#import <CoreData/CoreData.h>

@interface VentureMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) VentureDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
