//
//  GroupsListTVC.m
//  Venture
//
//  Created by Amy Bearman on 5/25/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "GroupsListTVC.h"
#import "Group.h"
#import "VentureDatabase.h"

@interface GroupsListTVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) BOOL isLoggedIn;

@end

@implementation GroupsListTVC

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIEdgeInsets inset = UIEdgeInsetsMake(30, 0, 0, 0);
    self.tableView.contentInset = inset;
    self.title = @"Groups";
    
    VentureDatabase *ventureDb = [VentureDatabase sharedDefaultVentureDatabase];
    if (ventureDb.managedObjectContext) {
        self.managedObjectContext = ventureDb.managedObjectContext;
    } else {
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:VentureDatabaseAvailable
                                                                        object:ventureDb
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:^(NSNotification *note) {
                                                                        self.managedObjectContext = ventureDb.managedObjectContext;
                                                                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                    }];
    }
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataModelChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext];
    
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController {
    if (self.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
        request.predicate = nil; // Because we want ALL Regions
        
        NSSortDescriptor *nameSorter = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
        request.sortDescriptors = [NSArray arrayWithObjects:nameSorter, nil];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (void)handleDataModelChange:(NSNotification *)notification {
    [super performFetch];
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Group Cell" forIndexPath:indexPath];
    Group *group = [self.fetchedResultsController objectAtIndexPath:indexPath]; // Retrieves the Region object at this row
    
    cell.textLabel.text = group.name;
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *groupName = cell.textLabel.text;
    NSLog(@"%@", groupName);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangedGroup" object:groupName];
}

- (IBAction)createNewGroup:(UIBarButtonItem *)sender {
    NSLog(@"Create new group");
    
    // Send notification to central view
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateGroup" object:self];
}


@end




