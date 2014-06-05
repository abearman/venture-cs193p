//
// Created by Keenon Werling on 5/25/14.
// Copyright (c) 2014 Amy Bearman. All rights reserveGroupVCd.
//

#import "GroupVC.h"
#import "GroupsListTVC.h"
#import <FacebookSDK/FacebookSDK.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface GroupVC() <FBFriendPickerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIView *rightView;

@property (weak, nonatomic) IBOutlet UITextField *groupName;
@property (weak, nonatomic) IBOutlet UIView *addMembersView;
@property (weak, nonatomic) IBOutlet UIButton *addMembersButton;

@end

@implementation GroupVC

- (void) viewDidLoad {
    [self setUpGestureRecognizers];
    [self setUpNavigationBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"CreateGroup"
                                               object:nil];
    [self setUpAddMembersView];
}

- (IBAction)addMembers:(UIButton *)sender {
    NSLog(@"Hello!");
}

- (void) setUpAddMembersView {
    // border radius
    [self.addMembersView.layer setCornerRadius:20.0f];
    [self.addMembersButton.layer setCornerRadius:8.0f];
    
    // border
    [self.addMembersView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.addMembersView.layer setBorderWidth:0.5f];
}

- (void) receiveTestNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"CreateGroup"]) {
        NSLog (@"Successfully received the test notification!");
        
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
        self.addMembersView.hidden = YES;
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