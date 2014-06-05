//
//  Group.h
//  Venture
//
//  Created by Amy Bearman on 5/25/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message, Person;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *members;
@property (nonatomic, retain) NSSet *messages;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addMembersObject:(Person *)value;
- (void)removeMembersObject:(Person *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
