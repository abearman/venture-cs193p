//
//  GroupsListTVC.m
//  Venture
//
//  Created by Amy Bearman on 5/25/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "GroupsListTVC.h"

@interface GroupsListTVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) BOOL isLoggedIn;

@end

@implementation GroupsListTVC

- (void)viewDidLoad {
    UIEdgeInsets inset = UIEdgeInsetsMake(30, 0, 0, 0);
    self.tableView.contentInset = inset;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Create New Group" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Group" forIndexPath:indexPath];
    }
    
    return cell;
}

- (IBAction)createNewGroup:(UIButton *)sender {
    NSLog(@"Create new group");
    
    // Send notification to central view
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateGroup" object:self];
    
    //UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Create Group"];
    //[self.navigationController pushViewController:vc animated:NO];
}


@end




