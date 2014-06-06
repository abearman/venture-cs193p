//
//  Group.h
//  Venture1
//
//  Created by Amy Bearman on 6/6/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message, Person;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *members;
@property (nonatomic, retain) Message *messages;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addMembersObject:(Person *)value;
- (void)removeMembersObject:(Person *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

@end
