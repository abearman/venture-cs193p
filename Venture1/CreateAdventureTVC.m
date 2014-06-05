//
//  CreateAdventureTVC.m
//  Venture
//
//  Created by Amy Bearman on 5/22/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "CreateAdventureTVC.h"
#import "VentureServerLayer.h"
#import "TrackAdventureVC.h"

@interface CreateAdventureTVC () <UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic) VentureServerLayer *serverLayer;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSMutableArray *imageViews;

@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *descriptionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *categoryCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *photosCell;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;

@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (weak, nonatomic) IBOutlet UIView *photosView;

@property (strong, nonatomic) UIImageView *imageViewToDelete;
@property (strong, nonatomic) NSDictionary *adventureDict;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CreateAdventureTVC

@synthesize nameCell, descriptionCell, categoryCell, photosCell;
@synthesize nameTextField, descriptionTextField, categoryTextField;

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setUpNavigationBar];
    self.categories = [[NSArray alloc] initWithObjects:@"Restaurant", @"Park", @"Movie", @"Bar", @"Arts", @"Shopping", nil];
    [self setUpDelegates];
    [self initializeAllProperties];
    [self setUpUIofTable];
}

- (void) setUpUIofTable {
    self.descriptionCell.textLabel.text = @"Description";
    self.nameCell.textLabel.text = @"Name";
    self.categoryCell.textLabel.text = @"Category";
}

- (void) initializeAllProperties {
    self.imageViews = [[NSMutableArray alloc] init];
    self.serverLayer = [[VentureServerLayer alloc] init];
}

- (void) setUpDelegates {
    self.nameTextField.delegate = self;
    self.descriptionTextField.delegate = self;
    self.categoryTextField.delegate = self;
}

- (void) setUpNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"purple-gradient"] forBarMetrics:UIBarMetricsDefault];
    CGRect frame = CGRectMake(0, 0, 400, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Lobster" size:40];
    label.textColor = [UIColor whiteColor];
    label.text = @"Venture";
    label.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = label;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return self.nameCell;
    }
    if (indexPath.row == 1) {
        return self.descriptionCell;
    }
    if (indexPath.row == 2) {
        return self.categoryCell;
    }
    return self.photosCell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if (textField == self.categoryTextField) {
        [textField resignFirstResponder];
		self.actionSheet = [[UIActionSheet alloc] initWithTitle:
                                      NSLocalizedString(@"Category", @"")
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:
                                      NSLocalizedString(@"Restaurant", @""),
                                      NSLocalizedString(@"Park", @""),
                                      NSLocalizedString(@"Movie", @""),
                                       NSLocalizedString(@"Bar", @""),
                                       NSLocalizedString(@"Arts", @""),
                                       NSLocalizedString(@"Shopping", @""),
                                      nil];
		[self.actionSheet showInView:self.view];
	
    }
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex: (NSInteger)buttonIndex {
	NSLog(@"Index is %i", buttonIndex);
    if ([actionSheet.title isEqualToString:@"Category"]) {
        if (buttonIndex < [self.categories count]) {
            self.categoryTextField.text = NSLocalizedString([self.categories objectAtIndex:buttonIndex], @"");
        }
        
    } else if ([actionSheet.title isEqualToString:@"Photos"]) {
        // If they didn't hit the Cancel button
        if (buttonIndex < 2) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            
            if (buttonIndex == 0) { // Take Photo
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            } else if (buttonIndex == 1) { // Choose Existing
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }
}

- (IBAction)uploadPhotosClicked:(UIButton *)sender {
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:
                                  NSLocalizedString(@"Photos", @"")
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  NSLocalizedString(@"Take Photo", @""),
                                  NSLocalizedString(@"Choose Existing", @""),
                                  nil];
    [self.actionSheet showInView:self.view];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
   
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:chosenImage];
    [self.imageViews addObject:imageView];
    
    [self addPhoto];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)addPhoto {
    int x = self.scrollView.frame.size.height * ([self.imageViews count] - 1);
    UIImageView *imageView = [self.imageViews lastObject];
    
    imageView.frame = CGRectMake(x, 0, self.scrollView.frame.size.height, self.scrollView.frame.size.height);
    
    x += imageView.frame.size.width;
    self.scrollView.contentSize = CGSizeMake(x, self.scrollView.contentSize.height);
    [self.scrollView addSubview:imageView];
}

- (NSArray *)getBase64Images {
    NSMutableArray *mutablePhotosArray = [[NSMutableArray alloc] init]; // Array of photo data
    for (UIImageView *imageView in self.imageViews) {
        UIImage *image = imageView.image;
        NSData *imageData = UIImagePNGRepresentation(image);
        NSString *imageBase64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        [mutablePhotosArray addObject:imageBase64];
    }
    
    return [[NSArray alloc] initWithArray:mutablePhotosArray];
}

- (void) constructAndSubmitAdventureWithTitle: (NSString *)title {
    NSNumber *lat = [NSNumber numberWithFloat:self.annotation.coordinate.latitude];
    NSNumber *lng = [NSNumber numberWithFloat:self.annotation.coordinate.longitude];
    NSArray *imagesBase64 = [self getBase64Images];
    
    self.adventureDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          title, @"title",
                          descriptionTextField.text , @"description",
                          categoryTextField.text , @"type",
                          lat, @"lat",
                          lng, @"lng",
                          imagesBase64, @"photos",
                          nil];
    
    [self.serverLayer submitAdventure:self.adventureDict];
    
    TrackAdventureVC *tavc = [[self.navigationController viewControllers] objectAtIndex:0];
    [tavc.mapView removeAnnotation:tavc.selectedAnnotation];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = tavc.selectedAnnotation.coordinate;
    annotation.title = title;
    [tavc.mapView addAnnotation:annotation];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submitAdventure:(UIBarButtonItem *)sender {
    if ([nameTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Field" message:@"You must enter a title for this activity" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Submit", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    } else {
        [self constructAndSubmitAdventureWithTitle:nameTextField.text];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Submit"]) {
        NSString *titleText = [alertView textFieldAtIndex:0].text;
        [self constructAndSubmitAdventureWithTitle:titleText];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    NSString *nameInput = [[alertView textFieldAtIndex:0] text];
    if( [nameInput length] > 0) {
        return YES;
    }
    else {
        return NO;
    }
}


@end















