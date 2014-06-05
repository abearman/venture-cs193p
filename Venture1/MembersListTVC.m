//
//  MembersListTVC.m
//  Venture1
//
//  Created by Amy Bearman on 6/5/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "MembersListTVC.h"
#import "VentureDatabase.h"
#import "Person.h"

@interface MembersListTVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *currentGroupName;

@end

@implementation MembersListTVC

- (void)viewDidLoad {
    self.currentGroupName = @"Venture";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(membersChangedGroup:)
                                                 name:@"MembersChangedGroup"
                                               object:nil];
}

- (void) membersChangedGroup:(NSNotification *)notification {
    NSLog(@"Received notification to members changed group");
    self.currentGroupName = [notification object];
    [self setupFetchedResultsController];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIEdgeInsets inset = UIEdgeInsetsMake(30, 0, 0, 0);
    self.tableView.contentInset = inset;
    
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
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
        request.predicate = [NSPredicate predicateWithFormat:@"ANY groups.name like %@", self.currentGroupName];
        
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person Cell" forIndexPath:indexPath];
    Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath]; // Retrieves the Region object at this row
    
    cell.textLabel.text = person.name;
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    
    return cell;
}


@end
