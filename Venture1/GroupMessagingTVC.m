//
//  GroupMessagingTVC.m
//  Venture1
//
//  Created by Amy Bearman on 6/6/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "GroupMessagingTVC.h"
#import "VentureDatabase.h"
#import "Message.h"

@interface GroupMessagingTVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *currentGroupName;

@end

@implementation GroupMessagingTVC

/*- (void)viewDidAppear:(BOOL)animated {
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

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(membersChangedGroup:)
                                                 name:@"MembersChangedGroup"
                                               object:nil];
}

- (void) membersChangedGroup:(NSNotification *)notification {
    NSLog(@"Group messaging received notification to members changed group");
    self.currentGroupName = [notification object];
    [self setupFetchedResultsController];
}


- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataModelChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext];
    
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController {
    if (self.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
        request.predicate = [NSPredicate predicateWithFormat:@"group = %@", self.currentGroupName];
        
        
        NSSortDescriptor *nameSorter = [[NSSortDescriptor alloc] initWithKey:@"sender" ascending:YES selector:@selector(localizedStandardCompare:)];
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
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = message.message;

    cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:message.timestamp
                                                                                      dateStyle:NSDateFormatterShortStyle
                                                                                      timeStyle:NSDateFormatterFullStyle];
    
    return cell;
}*/

@end





