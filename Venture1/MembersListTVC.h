//
//  MembersListTVC.h
//  Venture1
//
//  Created by Amy Bearman on 6/5/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface MembersListTVC : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext; // Shows all Person's in a given context, Group

@end
