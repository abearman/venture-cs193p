//
//  Message.h
//  Venture1
//
//  Created by Amy Bearman on 6/6/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, Person;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Group *sender;
@property (nonatomic, retain) Person *group;

@end
