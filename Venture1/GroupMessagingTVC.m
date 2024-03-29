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
#import "Message.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "GroupMessagingTVC.h"

@interface GroupMessagingTVC () <UITableViewDelegate, UITableViewDataSource, ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, strong) NSString *currentGroupName;

@end

@implementation GroupMessagingTVC

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(membersChangedGroup:)
                                                 name:@"MembersChangedGroup"
                                               object:nil];
}

- (void) membersChangedGroup:(NSNotification *)notification {
    NSLog(@"Members received notification to members changed group");
    self.currentGroupName = [notification object];
    [self setupFetchedResultsController];
}

- (IBAction)addMembers:(UIBarButtonItem *)sender {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

# pragma mark People Picker

- (void) addMember:(NSString *)name forGroupName:(NSString *)groupName {
    // Get the Group the Person belongs to
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", groupName];
    NSError *error1;
    NSArray *groups = [self.managedObjectContext executeFetchRequest:request error:&error1];
    
    // Create the Person object to add to the Group
    Person *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
    person.name = name;
    person.groups = [[NSSet alloc] initWithObjects:[groups firstObject], nil];
    
    NSError *error2;
    if (![self.managedObjectContext save:&error2]) {
        NSLog(@"Whoops, couldn't save: %@", [error2 localizedDescription]);
    } else {
        NSLog(@"Successfully saved Person with name %@", person.name);
    }
}

- (void)peoplePickerNavigationControllerDidCancel: (ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    NSString *name = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSLog(@"%@", name);
    [self addMember:name forGroupName:self.currentGroupName];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    return NO;
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
        if (self.currentGroupName != nil) {
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
            request.predicate = [NSPredicate predicateWithFormat:@"group.name = %@", self.currentGroupName];
            
            NSSortDescriptor *dateSorter = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
            
            //NSSortDescriptor *nameSorter = [[NSSortDescriptor alloc] initWithKey:@"message" ascending:YES selector:@selector(localizedStandardCompare:)];
            request.sortDescriptors = [NSArray arrayWithObjects:dateSorter, nil];
            
            self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                managedObjectContext:self.managedObjectContext
                                                                                  sectionNameKeyPath:nil
                                                                                           cacheName:nil];
        }
        
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
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", message.sender.name, message.message];
    cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:message.timestamp
                                                               dateStyle:NSDateFormatterShortStyle
                                                               timeStyle:NSDateFormatterFullStyle];
    return cell;
}


@end
