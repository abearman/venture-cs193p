//
//  CreateGroupTVC.m
//  Venture
//
//  Created by Amy Bearman on 5/30/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "CreateGroupTVC.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface CreateGroupTVC ()

@end

@implementation CreateGroupTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationBar];
}

- (void) setUpNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"purple-gradient"] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/



@end
