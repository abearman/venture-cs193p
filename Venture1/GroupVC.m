//
// Created by Keenon Werling on 5/25/14.
// Copyright (c) 2014 Amy Bearman. All rights reserveGroupVCd.
//

#import "GroupVC.h"
#import "GroupsListTVC.h"
#import <FacebookSDK/FacebookSDK.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "VentureAppDelegate.h"
#import "Group.h"
#import "Person.h"
#import "VentureDatabase.h"
#import "VentureServerLayer.h"
#import "VentureLocationTracker.h"

@interface GroupVC() <FBFriendPickerDelegate, UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@property (weak, nonatomic) IBOutlet UITextField *groupName;
@property (weak, nonatomic) IBOutlet UIView *addMembersView;
@property (weak, nonatomic) IBOutlet UIButton *addMembersButton;

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) UIManagedDocument *document;

@property (nonatomic) VentureLocationTracker *locationTracker;
@property (nonatomic) VentureServerLayer *serverLayer;

@property (nonatomic) NSTimer *timer;

@end

@implementation GroupVC

@synthesize context;
@synthesize document;

- (void) viewDidLoad {
    [self setUpGestureRecognizers];
    [self setUpNavigationBar];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phoneNumber = [defaults stringForKey:@"phone"];

    if (phoneNumber == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Phone Number" message:@"Enter your phone number" delegate:self cancelButtonTitle:@"Leave" otherButtonTitles:@"Submit", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createGroup:)
                                                 name:@"CreateGroup"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changedGroup:)
                                                 name:@"ChangedGroup"
                                               object:nil];

    self.locationTracker = [[VentureLocationTracker alloc] init];
    self.serverLayer = [[VentureServerLayer alloc] initWithLocationTracker:self.locationTracker];

    [self setUpAddMembersView];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateChatView) userInfo:nil repeats:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%i",buttonIndex);
    NSString *phone = [alertView textFieldAtIndex:0].text;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:phone forKey:@"phone"];
    [self.serverLayer associatePhone:phone];
}


- (void) updateChatView {
    [self.serverLayer getGroups:^(NSMutableDictionary *groupData) {
        // TODO: Update views with group data
        NSLog(@"%@",groupData);
    }];
}

- (void) viewDidAppear:(BOOL)animated {
    [self.groupName setBackgroundColor:[UIColor clearColor]];
    if ([self.groupName.text isEqualToString:@""]) {
        self.groupName.enabled = YES;
    } else {
        self.groupName.enabled = NO;
    }
    
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

- (IBAction)addMembers:(UIButton *)sender {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

# pragma mark People Picker

- (void) addMember:(NSString *)name forGroupName:(NSString *)groupName withPhone:(NSString *)phoneNumber {
    // Get the Group the Person belongs to
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", groupName];
    NSError *error1;
    NSArray *groups = [self.managedObjectContext executeFetchRequest:request error:&error1];
    
    // Create the Person object to add to the Group
    Person *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
    person.name = name;
    Group *group = [groups firstObject];
    NSString *foundGroupName = group.name;
    person.groups = [[NSSet alloc] initWithObjects:[groups firstObject], nil];
    
    NSError *error2;
    if (![self.managedObjectContext save:&error2]) {
        NSLog(@"Whoops, couldn't save: %@", [error2 localizedDescription]);
    } else {
        NSLog(@"Successfully saved Person with name %@", person.name);
        [self.serverLayer addAddressBookFriend:phoneNumber toGroup:groupName successFailureCallback:^(BOOL success) {
            if (!success) {
                // TODO: Send text message dialog: "You're invited to download Venture!"
            }
        }];
    }
}

- (void)peoplePickerNavigationControllerDidCancel: (ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    NSString *name = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *phone = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonPhoneMainLabel);
    NSLog(@"%@ - %@", name, phone);
    [self addMember:name forGroupName:self.groupName.text withPhone:phone];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    return NO;
}

- (void) setUpAddMembersView {
    // border radius
    [self.addMembersView.layer setCornerRadius:20.0f];
    [self.addMembersButton.layer setCornerRadius:10.0f];
    
    // border
    [self.addMembersView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.addMembersView.layer setBorderWidth:0.5f];
}

- (void) unrollCenterView {
    // Unroll the groups list view
    self.leftView.hidden = NO;
    self.rightView.hidden = YES;
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.centerView.frame = CGRectMake(0.0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         [self.groupName becomeFirstResponder];
                     }];
}

- (void) changedGroup:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"ChangedGroup"]) {
        NSLog(@"Received notification to change group");
        
        self.groupName.text = [notification object];
        self.groupName.enabled = NO; // Set the group title to be non-editable
        [self unrollCenterView];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MembersChangedGroup" object:self.groupName.text];
        // Load group conversation
    }
}

- (void) createGroup:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"CreateGroup"]) {
        self.groupName.text = @"";
        self.groupName.enabled = YES; // Set the group title to be editable
        [self unrollCenterView];
        self.addMembersView.hidden = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MembersChangedGroup" object:self.groupName.text];
    }
}


- (void)createGroupWithName:(NSString *)name {
    Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
    group.name = name;
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    } else {
        NSLog(@"Successfully saved group with name %@", group.name);
        [self.serverLayer createGroup:name];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.addMembersView.alpha = 0.0;
    self.addMembersView.hidden = NO;
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.addMembersView.alpha = 1.0;
                         self.addMembersView.hidden = NO;
                     }
                     completion:nil];
    
    [textField resignFirstResponder];
    [self createGroupWithName:textField.text];
    return YES;
}

- (void) setUpNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"purple-gradient"] forBarMetrics:UIBarMetricsDefault];
}

- (void) setUpGestureRecognizers {
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    
    [pan requireGestureRecognizerToFail:swipeRight];
    [pan requireGestureRecognizerToFail:swipeLeft];
    
    [self.centerView addGestureRecognizer:swipeRight];
    [self.centerView addGestureRecognizer:swipeLeft];
    [self.centerView addGestureRecognizer:pan];
}

- (void) panDetected:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:gesture.view];
    CGFloat xTranslate = gesture.view.center.x + translation.x;
    gesture.view.center = CGPointMake(xTranslate, gesture.view.center.y);
    [gesture setTranslation:CGPointMake(0, 0) inView: gesture.view];
    
    if (self.centerView.frame.origin.x < 0.0) {
        self.leftView.hidden = YES;
        self.rightView.hidden = NO;
    } else {
        self.leftView.hidden = NO;
        self.rightView.hidden = YES;
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.centerView.frame = CGRectMake(0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                         }
                         completion:nil];
    }
}

- (void) swipeRight:(UISwipeGestureRecognizer *)gesture {
    CGFloat x = self.centerView.frame.origin.x;
    if (x == 0.0) {
        self.leftView.hidden = NO;
        self.rightView.hidden = YES;
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.centerView.frame = CGRectMake(240.0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                         }
                         completion:nil];
    } else if (x == -240.0) {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.centerView.frame = CGRectMake(0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                         }
                         completion:nil];
    }
}

- (void) swipeLeft:(UISwipeGestureRecognizer *)gesture {
    CGFloat x = self.centerView.frame.origin.x;
    if (x == 240.0) {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.centerView.frame = CGRectMake(0.0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                         }
                         completion:nil];
    } else if (x == 0.0) {
        self.leftView.hidden = YES;
        self.rightView.hidden = NO;
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.centerView.frame = CGRectMake(-240.0, self.centerView.frame.origin.y, self.centerView.frame.size.width, self.centerView.frame.size.height);
                         }
                         completion:nil];
    }
}

@end