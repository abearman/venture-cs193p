//
//  Person.h
//  Venture
//
//  Created by Amy Bearman on 5/25/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSSet *groups;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(NSManagedObject *)value;
- (void)removeGroupsObject:(NSManagedObject *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

@end
