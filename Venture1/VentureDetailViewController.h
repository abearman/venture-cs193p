//
//  VentureDetailViewController.h
//  Venture1
//
//  Created by Amy Bearman on 5/31/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VentureDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
